module NotificationDeliveryResolvers
  # Outcome creation and edits share recipient rules while retaining distinct
  # occurrence identities and notification kinds in their concrete resolvers.
  class OutcomeChange < NotificationDeliveryResolver
    private

    def recipients_by_channel
      outcome = notification.subject_model
      raise ArgumentError, "outcome notification subject must be an Outcome" unless outcome.is_a?(Outcome)

      explicit_scope = explicit_users.active
      email_members = if notification.kind == "outcome_created"
        outcome.topic.email_normal_members
      else
        outcome.topic.email_enabled_members
      end
      email_explicit = email_members
                         .where("users.id": explicit_scope.select(:id))
                         .where.not(id: audience_ids("newly_mentioned_user_ids"))
      {
        "in_app" => outcome.topic.members
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
