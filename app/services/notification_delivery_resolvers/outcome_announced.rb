module NotificationDeliveryResolvers
  class OutcomeAnnounced < NotificationDeliveryResolver
    private

    def recipients_by_channel
      outcome = notification.subject_model
      raise ArgumentError, "outcome_announced subject must be an Outcome" unless outcome.is_a?(Outcome)

      recipients = explicit_users.active
      {
        "in_app" => outcome.topic.app_notification_members
                           .where("users.id": recipients.select(:id))
                           .where.not(id: notification.actor_id).to_a,
        "email" => outcome.topic.email_notification_members
                          .where("users.id": recipients.no_spam_complaints.select(:id)).to_a
      }
    end
  end
end
