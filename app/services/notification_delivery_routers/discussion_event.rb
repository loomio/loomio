module NotificationDeliveryRouters
  # Discussion creation, edits, and announcements share one directed-delivery
  # policy. The actor is excluded, and a separate mention occurrence owns every
  # channel for newly mentioned users. Announcements have no new mentions, so
  # their snapshotted exclusion is empty.
  class DiscussionEvent < NotificationDeliveryRouter
    subject_model_class Discussion

    def recipients_by_channel
      discussion = subject_model
      in_app_recipients = discussion.topic.members
                                        .where("users.id": user_recipients.active.select(:id))
                                        .where.not(id: notification.actor_id)
                                        .where.not(id: audience_value_ids("newly_mentioned_user_ids"))

      recipients(
        in_app_recipients,
        volume: discussion.topic,
        chatbots: (discussion.group&.chatbots || Chatbot.none)
                    .where(id: notification.recipient_chatbot_ids)
      )
    end
  end
end
