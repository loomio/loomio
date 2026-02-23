class DiscussionService
  TOPIC_ATTRS = %w[group_id private max_depth newest_first closed_at pinned_at].freeze

  def self.build(params:, actor:)
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*TOPIC_ATTRS)

    discussion = Discussion.new
    discussion.assign_attributes_and_files(params)
    discussion.author = actor

    topic = Topic.new(topic_params)
    topic.topicable = discussion

    discussion.topic = topic
    discussion
  end

  def self.create(params:, actor:)
    discussion = build(params: params, actor: actor)

    Discussion.transaction do
      actor.ability.authorize!(:create, discussion)
      discussion.save!
      discussion.topic.update_sequence_info!

      UserInviter.authorize!(
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        model: discussion,
        actor: actor
      )

      TopicReader.for(
        user: actor, topic: discussion.topic
      ).update(
        admin: true, guest: !discussion.group_id.present?, inviter_id: actor.id
      )

      users = TopicService.add_users(
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        topic: discussion.topic,
        actor: actor
      )

      EventBus.broadcast('discussion_create', discussion, actor)

      Events::NewDiscussion.publish!(
        discussion: discussion,
        recipient_user_ids: users.pluck(:id),
        recipient_chatbot_ids: params[:recipient_chatbot_ids],
        recipient_audience: params[:recipient_audience]
      )
    end
    discussion
  end

  def self.update(discussion:, actor:, params:)
    actor.ability.authorize! :update, discussion

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: discussion,
                           actor: actor)


    discussion.assign_attributes_and_files(params.except(:group_id))
    return false unless discussion.valid?
    rearrange = discussion.topic.max_depth_changed?
    Discussion.transaction do
      discussion.save!

      discussion.update_versions_count
      RepairThreadWorker.perform_async(discussion.topic_id) if rearrange

      users = TopicService.add_users(topic: discussion.topic,
                                     actor: actor,
                                     user_ids: params[:recipient_user_ids],
                                     emails: params[:recipient_emails],
                                     audience: params[:recipient_audience])

      Events::DiscussionEdited.publish!(discussion: discussion,
                                        actor: actor,
                                        recipient_user_ids: users.pluck(:id),
                                        recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                        recipient_audience: params[:recipient_audience],
                                        recipient_message: params[:recipient_message])
    end
  end

  def self.discard(discussion:, actor:)
    actor.ability.authorize!(:discard, discussion)
    Discussion.transaction do
      discussion.update(discarded_at: Time.now, discarded_by: actor.id)

      discussion.polls.update_all(discarded_at: Time.now, discarded_by: actor.id)
      GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)

      EventBus.broadcast('discussion_discard', discussion, actor)
      discussion.created_event
    end
  end

  def self.extract_link_preview_urls(discussion)
    urls = discussion.link_previews.map { |lp| lp['url'] }
    discussion.items.each do |event|
      if event.eventable.present? && event.eventable.respond_to?(:link_previews)
        urls.concat(event.eventable.link_previews.map {|lp| lp['url']})
      end
    end
    urls.compact.uniq
  end
end
