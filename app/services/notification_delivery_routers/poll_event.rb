module NotificationDeliveryRouters
  # Poll announcements, edits, and reminders notify selected topic members
  # other than the actor. A separate mention occurrence owns every channel for
  # newly mentioned users.
  class PollEvent < NotificationDeliveryRouter
    handles :poll_announced, :poll_edited, :poll_reminder

    def recipients_by_channel
      poll = subject_model
      users = poll.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: notification.actor_id)
              .where.not(id: recipient_context_ids("newly_mentioned_user_ids"))
      recipients(users, volume: poll.topic)
    end
  end
end
