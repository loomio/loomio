class DiscussionService
  TOPIC_ATTRS = %w[group_id private max_depth newest_first allow_concurrent_polls allow_comments allow_reactions comment_length_max locked_at pinned_at tags].freeze

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
      TagService.authorize_create_tag_names!(discussion.group, discussion.topic.tags, actor)
      discussion.save!
      discussion.topic.update_sequence_info!

      TopicReader.for(
        user: actor, topic: discussion.topic
      ).update(
        admin: true, guest: !discussion.group_id.present?, inviter_id: actor.id
      )

      UserInviter.authorize!(
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        model: discussion,
        actor: actor
      )

      users = TopicService.add_users(
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        topic: discussion.topic,
        actor: actor
      )

      Sentry.metrics.count("discussion.create")
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


    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*TOPIC_ATTRS)
    discussion.assign_attributes_and_files(params.except(:group_id))
    unless discussion.valid?
      Sentry.metrics.count("discussion.update_failed", attributes: { columns: discussion.errors.attribute_names.join(',') })
      return false
    end
    Discussion.transaction do
      TagService.authorize_create_tag_names!(discussion.group, topic_params[:tags], actor) if topic_params.key?(:tags)
      discussion.topic.update!(topic_params) if topic_params.any?
      discussion.save!

      discussion.update_versions_count

      users = TopicService.add_users(topic: discussion.topic,
                                     actor: actor,
                                     user_ids: params[:recipient_user_ids],
                                     emails: params[:recipient_emails],
                                     audience: params[:recipient_audience])

      Sentry.metrics.count("discussion.update")
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
      ReindexDiscussionWorker.perform_later(discussion.id)

      Sentry.metrics.count("discussion.discard")
      EventBus.broadcast('discussion_discard', discussion, actor)
      discussion.created_event
    end
  end
end
