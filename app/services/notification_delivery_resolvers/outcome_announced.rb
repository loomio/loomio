module NotificationDeliveryResolvers
  class OutcomeAnnounced < NotificationDeliveryResolver
    private

    def recipients_by_channel
      outcome = notification.subject_model
      raise ArgumentError, "outcome_announced subject must be an Outcome" unless outcome.is_a?(Outcome)

      recipients = explicit_users.active
      in_app_scope = outcome.topic.members
                            .where("users.id": recipients.select(:id))
      user_recipients_by_channel(
        in_app_scope,
        email: outcome.topic.email_enabled_members,
        push: outcome.topic.push_enabled_members
      )
    end
  end
end
