module NotificationDeliveryResolvers
  class PollAnnounced < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject
      raise ArgumentError, "poll_announced subject must be a Poll" unless poll.is_a?(Poll)

      recipients = explicit_users.active
      chatbots = poll.group.chatbots
      {
        "in_app" => recipients.to_a,
        "email" => poll.topic.volume_gte_normal_members
                       .where("users.id": recipients.no_spam_complaints.select(:id)).to_a,
        "chatbot" => chatbots.where(id: notification.recipient_chatbot_ids)
                             .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind)).to_a
      }
    end
  end
end
