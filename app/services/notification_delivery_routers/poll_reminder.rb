module NotificationDeliveryRouters
  class PollReminder < NotificationDeliveryRouter
    subject_model_class Poll

    def recipients_by_channel
      poll = subject_model
      users = poll.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: notification.actor_id)
      chatbots = poll.group.chatbots
      recipients(
        users,
        volume: poll.topic,
        chatbots: chatbots.where(id: notification.recipient_chatbot_ids)
                          .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind))
      )
    end
  end
end
