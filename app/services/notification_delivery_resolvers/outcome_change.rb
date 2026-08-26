module NotificationDeliveryResolvers
  # Outcome creation and edits share recipient rules while retaining distinct
  # occurrence identities and notification kinds in their concrete resolvers.
  class OutcomeChange < NotificationDeliveryResolver
    private

    def recipients_by_channel
      outcome = notification.subject_model
      raise ArgumentError, "outcome notification subject must be an Outcome" unless outcome.is_a?(Outcome)

      explicit_scope = explicit_users.active
      email_explicit = outcome.topic.volume_gte_normal_members
                              .where("users.id": explicit_scope.no_spam_complaints.select(:id))
                              .where.not(id: audience_ids("newly_mentioned_user_ids"))
      if notification.kind == "outcome_created"
        email_explicit = email_explicit.where.not(id: outcome.topic.volume_loud_members.select(:id))
      end
      {
        "in_app" => outcome.topic.volume_gte_quiet_members
                           .where("users.id": explicit_scope.select(:id))
                           .where.not(id: notification.actor_id).to_a,
        "email" => email_explicit.to_a,
        "chatbot" => (outcome.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids).to_a
      }
    end

    def audience_ids(key)
      Array(notification.audience_values[key]).map(&:to_i)
    end
  end
end
