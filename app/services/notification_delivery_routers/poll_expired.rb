module NotificationDeliveryRouters
  class PollExpired < NotificationDeliveryRouter
    subject_model_class Poll

    def recipients_by_channel
      poll = subject_model
      in_app_recipients = poll.topic.members
                                  .where("users.id": User.active.where(id: poll.author_id).select(:id))
      recipients(
        in_app_recipients,
        volume: poll.topic,
        chatbots: (poll.group&.chatbots || Chatbot.none)
                    .where("? = ANY(chatbots.event_kinds)", notification.kind)
      )
    end
  end
end
