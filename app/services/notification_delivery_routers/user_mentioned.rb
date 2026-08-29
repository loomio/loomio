module NotificationDeliveryRouters
  class UserMentioned < NotificationDeliveryRouter
    def recipients_by_channel
      recipients(user_recipients.active.verified, volume: subject_volume_source)
    end
  end
end
