module NotificationDeliveryRouters
  class PollReminder < NotificationDeliveryRouter
    handles :poll_reminder

    def recipients_by_channel
      poll = subject_model
      users = poll.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: notification.actor_id)
      recipients(users, volume: poll.topic)
    end
  end
end
