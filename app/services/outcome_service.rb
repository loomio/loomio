class OutcomeService
  def self.invite(outcome:, actor:, params:)
    actor.ability.authorize! :announce, outcome

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: outcome,
                           actor: actor)

    users = nil
    Outcome.transaction do
      users = UserInviter.where_or_create!(actor: actor,
                                           model: outcome,
                                           emails: params[:recipient_emails],
                                           user_ids: params[:recipient_user_ids],
                                           audience: params[:recipient_audience],
                                           include_actor: params[:include_actor].present?)

      NotificationService.create!(
        kind: "outcome_announced",
        subject: outcome,
        actor: actor,
        recipient_user_ids: users.pluck(:id)
      )
    end
    users
  end

  def self.create(outcome:, actor:, params: {})
    actor.ability.authorize! :create, outcome

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: outcome,
                           actor: actor)

    outcome.assign_attributes(author: actor)
    unless outcome.valid?
      Sentry.metrics.count("outcome.create_failed", attributes: { columns: outcome.errors.attribute_names.join(',') })
      return false
    end
    topic_item = Outcome.transaction do
      outcome.poll.outcomes.update_all(latest: false)
      outcome.save!

      users = UserInviter.where_or_create!(actor: actor,
                                           emails: params[:recipient_emails],
                                           user_ids: params[:recipient_user_ids],
                                           model: outcome,
                                           audience: params[:recipient_audience],
                                           include_actor: params[:include_actor].present?)

      audience_values = mention_audience_values(outcome)
      topic_item = TopicItems::OutcomeCreated.create!(itemable: outcome)
      if users.any? || Array(params[:recipient_chatbot_ids]).compact.any?
        NotificationService.create!(
          kind: "outcome_created",
          subject: outcome,
          actor: actor,
          recipient_user_ids: users.pluck(:id),
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          audience_values: audience_values,
          topic_item: topic_item
        )
      end
      MentionNotificationService.create!(
        subject: outcome,
        actor: actor,
        already_notified_user_ids: users.pluck(:id),
        topic_item: topic_item
      )
      topic_item
    end

    Sentry.metrics.count("outcome.create")
    EventBus.broadcast 'outcome_create', outcome, actor
    topic_item
  end

  def self.update(outcome:, actor:, params: {})
    actor.ability.authorize! :update, outcome

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: outcome,
                           actor: actor)

    outcome.assign_attributes_and_files(params.slice(:review_on, :statement, :statement_format, :event_summary, :event_location, :files, :image_files, :link_previews, :poll_option_id))
    unless outcome.valid?
      Sentry.metrics.count("outcome.update_failed", attributes: { columns: outcome.errors.attribute_names.join(',') })
      return false
    end

    Outcome.transaction do
      outcome.save!
      outcome.update_versions_count

      users = UserInviter.where_or_create!(actor: actor,
                                           emails: params[:recipient_emails],
                                           user_ids: params[:recipient_user_ids],
                                           model: outcome,
                                           audience: params[:recipient_audience],
                                           include_actor: params[:include_actor].present?)

      audience_values = mention_audience_values(outcome)
      if users.any? || Array(params[:recipient_chatbot_ids]).compact.any?
        NotificationService.create!(
          kind: "outcome_updated",
          subject: outcome,
          actor: actor,
          recipient_user_ids: users.pluck(:id),
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          audience_values: audience_values
        )
      end
      MentionNotificationService.create!(
        subject: outcome,
        actor: actor,
        already_notified_user_ids: users.pluck(:id)
      )
    end

    Sentry.metrics.count("outcome.update")
    EventBus.broadcast 'outcome_update', outcome, actor
    MessageChannelService.publish_topic_model(outcome)
    outcome
  end

  def self.publish_review_due
    Outcome.review_due_not_published(Time.zone.today).each do |outcome|
      NotificationService.create!(
        kind: "outcome_review_due",
        subject: outcome,
        actor: outcome.author
      )
    end
  end

  def self.mention_audience_values(outcome)
    {
      newly_mentioned_user_ids: outcome.newly_mentioned_users.pluck(:id),
      mentioned_user_ids: outcome.mentioned_users.pluck(:id),
      mentioned_group_user_ids: outcome.mentioned_group_users.pluck(:id)
    }
  end
  private_class_method :mention_audience_values
end
