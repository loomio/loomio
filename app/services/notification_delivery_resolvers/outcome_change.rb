module NotificationDeliveryResolvers
  # Outcome creation and edits share recipient rules while retaining distinct
  # occurrence identities and notification kinds in their concrete resolvers.
  class OutcomeChange < NotificationDeliveryResolver
    private

    # Outcome forms can explicitly include their actor, so recipient IDs are
    # authoritative here. A separate mention occurrence owns every channel for
    # newly mentioned users.
    def recipients_by_channel
      outcome = notification.subject_model
      raise ArgumentError, "outcome notification subject must be an Outcome" unless outcome.is_a?(Outcome)

      explicit_scope = explicit_users.active

      recipient_scope = outcome.topic.members
                               .where("users.id": explicit_scope.select(:id))
                               .where.not(id: audience_ids("newly_mentioned_user_ids"))
      user_recipients_by_channel(
        recipient_scope,
        email: outcome.topic.email_enabled_members,
        push: outcome.topic.push_enabled_members
      ).merge(
        "chatbot" => (outcome.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids)
      )
    end

  end
end
