module NotificationDeliveryResolvers
  class PollAnnounced < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject_model
      raise ArgumentError, "poll_announced subject must be a Poll" unless poll.is_a?(Poll)

      chatbots = poll.group.chatbots
      user_recipients_by_channel(
        explicit_users.active,
        email: poll.topic.email_enabled_members,
        push: poll.topic.push_enabled_members
      ).merge(
        "chatbot" => chatbots.where(id: notification.recipient_chatbot_ids)
                             .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind))
      )
    end
  end
end
