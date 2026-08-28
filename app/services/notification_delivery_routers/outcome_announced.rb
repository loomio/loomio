module NotificationDeliveryRouters
  class OutcomeAnnounced < NotificationDeliveryRouter
    subject_model_class Outcome

    def recipients_by_channel
      outcome = subject_model
      in_app_recipients = outcome.topic.members
                                           .where("users.id": user_recipients.active.select(:id))
      recipients(in_app_recipients, volume: outcome.topic)
    end
  end
end
