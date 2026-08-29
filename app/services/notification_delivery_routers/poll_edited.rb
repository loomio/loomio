module NotificationDeliveryRouters
  class PollEdited < NotificationDeliveryRouter
    subject_model_class Poll

    # Poll edits notify only selected users other than the actor. A separate
    # mention occurrence owns every channel for newly mentioned users.
    def recipients_by_channel
      poll = subject_model
      users = poll.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: notification.actor_id)
              .where.not(id: recipient_context_ids("newly_mentioned_user_ids"))
      recipients(
        users,
        volume: poll.topic,
        chatbots: (poll.group&.chatbots || Chatbot.none)
                    .where(id: notification.recipient_chatbot_ids)
      )
    end
  end
end
