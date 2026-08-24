class DiscussionService
  TOPIC_ATTRS = %w[group_id private max_depth newest_first allow_concurrent_polls allow_comments allow_reactions comment_length_max locked_at pinned_at tags].freeze
  TOPIC_ATTRS_UPDATE = (TOPIC_ATTRS - %w[group_id tags]).freeze

  def self.build(params:, actor:)
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*TOPIC_ATTRS)
    unless topic_params.key?(:private)
      topic_params[:private] = TopicService.private_default(group_id: topic_params[:group_id])
    end

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
      discussion.topic.save!
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

      mention_audience = {
        newly_mentioned_user_ids: discussion.newly_mentioned_users.pluck(:id),
        mentioned_user_ids: discussion.mentioned_users.pluck(:id),
        mentioned_group_user_ids: discussion.mentioned_group_users.pluck(:id)
      }

      Sentry.metrics.count("discussion.create")

      topic_item = TopicItems::NewDiscussion.create!(itemable: discussion)

      if users.any? || Array(params[:recipient_chatbot_ids]).compact.any?
        NotificationService.create!(
          kind: "new_discussion",
          subject: discussion,
          actor: actor,
          recipient_user_ids: users.pluck(:id),
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_message: params[:recipient_message],
          audience_values: mention_audience,
          topic_item: topic_item
        )
      end
      MentionNotificationService.create!(
        subject: discussion,
        actor: actor,
        already_notified_user_ids: users.pluck(:id),
        topic_item: topic_item
      )
    end
    EventBus.broadcast('discussion_create', discussion, actor)
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
    topic_params = params.extract!(*TOPIC_ATTRS).slice(*TOPIC_ATTRS_UPDATE)
    discussion.assign_attributes_and_files(params)
    unless discussion.valid?
      Sentry.metrics.count("discussion.update_failed", attributes: { columns: discussion.errors.attribute_names.join(',') })
      return false
    end
    topic_item = nil
    Discussion.transaction do
      discussion.topic.update!(topic_params) if topic_params.any?
      discussion.save!

      discussion.update_versions_count

      users = TopicService.add_users(topic: discussion.topic,
                                     actor: actor,
                                     user_ids: params[:recipient_user_ids],
                                     emails: params[:recipient_emails],
                                     audience: params[:recipient_audience])

      mention_audience = {
        newly_mentioned_user_ids: discussion.newly_mentioned_users.pluck(:id),
        mentioned_user_ids: discussion.mentioned_users.pluck(:id),
        mentioned_group_user_ids: discussion.mentioned_group_users.pluck(:id)
      }

      Sentry.metrics.count("discussion.update")
      if params[:recipient_message].present?
        topic_item = TopicItems::DiscussionEdited.create!(
          itemable: discussion,
          user: actor
        )
      end
      if topic_item || users.any? || Array(params[:recipient_chatbot_ids]).compact.any?
        NotificationService.create!(
          kind: "discussion_edited",
          subject: discussion,
          actor: actor,
          recipient_user_ids: users.pluck(:id),
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_message: params[:recipient_message],
          audience_values: mention_audience,
          topic_item: topic_item
        )
      end
      MentionNotificationService.create!(
        subject: discussion,
        actor: actor,
        already_notified_user_ids: users.pluck(:id),
        topic_item: topic_item
      )
      topic_item
    end
    MessageChannelService.publish_topic_model(discussion) unless topic_item
    topic_item || discussion
  end

  def self.discard(discussion:, actor:)
    actor.ability.authorize!(:discard, discussion)
    TopicService.discard_without_authorization(topic: discussion.topic, actor: actor)
    discussion.reload
    Sentry.metrics.count("discussion.discard")
    discussion.created_topic_item
  end
end
