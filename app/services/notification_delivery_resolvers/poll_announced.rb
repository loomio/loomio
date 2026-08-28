module NotificationDeliveryResolvers
  class PollAnnounced < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject_model
      raise ArgumentError, "poll_announced subject must be a Poll" unless poll.is_a?(Poll)

      recipients = explicit_users.active
      chatbots = poll.group.chatbots
      {
        "in_app" => recipients.to_a,
        "email" => poll.topic.email_enabled_members
                       .where("users.id": recipients.select(:id)).to_a,
        "chatbot" => chatbots.where(id: notification.recipient_chatbot_ids)
                             .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind)).to_a
      }
    end
  end
end
