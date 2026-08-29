module NotificationDeliveryRouters
  class OutcomeAnnounced < NotificationDeliveryRouter
    def recipients_by_channel
      outcome = subject_model
      users = outcome.topic.members
              .where("users.id": user_recipients.active.select(:id))
      recipients(users, volume: outcome.topic)
    end
  end
end
