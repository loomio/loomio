module NotificationDeliveryRouters
  class UserMentioned < NotificationDeliveryRouter
    handles :user_mentioned, :comment_replied_to

    def recipients_by_channel
      recipients(user_recipients.active.verified, volume: subject_volume_source)
    end
  end
end
