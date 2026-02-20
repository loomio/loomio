class DiscussionService
  TOPIC_ATTRS = %w[group_id private max_depth newest_first closed_at pinned_at].freeze

  def self.create(params:, actor:)
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*TOPIC_ATTRS)

    Discussion.transaction do
      discussion = Discussion.new
      discussion.assign_attributes_and_files(params)
      discussion.author = actor

      topic = Topic.new(
        topicable: discussion,
        group_id: topic_params[:group_id],
        private: topic_params.key?(:private) ? topic_params[:private] : true,
        max_depth: topic_params[:max_depth] || 3,
        newest_first: !!topic_params[:newest_first],
        closed_at: topic_params[:closed_at],
        pinned_at: topic_params[:pinned_at]
      )
      discussion.topic = topic

      return { discussion: discussion, topic: topic } if !discussion.valid? || !topic.valid?

      actor.ability.authorize!(:create, discussion)

      discussion.save!

      UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                             emails: params[:recipient_emails],
                             audience: params[:recipient_audience],
                             model: discussion,
                             actor: actor)

      TopicReader.for(user: actor, topic: topic)
                 .update(admin: true, guest: !topic.group_id.present?, inviter_id: actor.id)

      users = TopicService.add_users(user_ids: params[:recipient_user_ids],
                                     emails: params[:recipient_emails],
                                     audience: params[:recipient_audience],
                                     topic: topic,
                                     actor: actor)

      EventBus.broadcast('discussion_create', discussion, actor)
      event = Events::NewDiscussion.publish!(discussion: discussion,
                                             recipient_user_ids: users.pluck(:id),
                                             recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                             recipient_audience: params[:recipient_audience])

      { discussion: discussion, topic: topic, event: event }
    end
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
    rearrange = discussion.max_depth_changed?
    Discussion.transaction do
      discussion.save!

      discussion.update_versions_count
      RepairThreadWorker.perform_async(discussion.topic_id) if rearrange

      users = TopicService.add_users(topic: topic,
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
