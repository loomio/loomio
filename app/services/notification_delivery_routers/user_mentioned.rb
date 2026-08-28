module NotificationDeliveryRouters
  class UserMentioned < NotificationDeliveryRouter
    subject_model_class HasMentions

    def recipients_by_channel
      recipients(user_recipients.active.verified, volume: subject_volume_source)
    end
  end
end
