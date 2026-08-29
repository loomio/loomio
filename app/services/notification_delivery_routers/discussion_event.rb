module NotificationDeliveryRouters
  # Discussion creation, edits, and announcements share one directed-delivery
  # policy. The actor is excluded, and a separate mention occurrence owns every
  # channel for newly mentioned users. Announcements have no new mentions, so
  # their snapshotted exclusion is empty.
  class DiscussionEvent < NotificationDeliveryRouter
    def recipients_by_channel
      discussion = subject_model
      users = discussion.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: notification.actor_id)
              .where.not(id: recipient_context_ids("newly_mentioned_user_ids"))

      recipients(users, volume: discussion.topic)
    end
  end
end
