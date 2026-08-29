module NotificationDeliveryRouters
  class PollEdited < NotificationDeliveryRouter
    # Poll edits notify only selected users other than the actor. A separate
    # mention occurrence owns every channel for newly mentioned users.
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
