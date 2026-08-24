module NotificationDeliveryResolvers
  class PollReminder < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject_model
      raise ArgumentError, "poll_reminder subject must be a Poll" unless poll.is_a?(Poll)

      recipients = explicit_users.active
      chatbots = poll.group.chatbots
      {
        "in_app" => poll.topic.volume_gte_quiet_members
                       .where("users.id": recipients.select(:id))
                       .where.not(id: notification.actor_id).to_a,
        "email" => poll.topic.volume_gte_normal_members
                      .where("users.id": recipients.no_spam_complaints.select(:id)).to_a,
        "chatbot" => chatbots.where(id: notification.recipient_chatbot_ids)
                             .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind)).to_a
      }
    end
  end
end
