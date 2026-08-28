module NotificationDeliveryRouters
  class PollAnnounced < NotificationDeliveryRouter
    subject_model_class Poll

    def recipients_by_channel
      poll = subject_model
      chatbots = poll.group.chatbots
      recipients(
        user_recipients.active,
        volume: poll.topic,
        chatbots: chatbots.where(id: notification.recipient_chatbot_ids)
                          .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind))
      )
    end
  end
end
