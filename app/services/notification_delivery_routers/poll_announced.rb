module NotificationDeliveryRouters
  class PollAnnounced < NotificationDeliveryRouter
    handles :poll_announced

    def recipients_by_channel
      poll = subject_model
      recipients(user_recipients.active, volume: poll.topic)
    end
  end
end
