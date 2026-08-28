module NotificationDeliveryResolvers
  class PollReminder < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject_model
      raise ArgumentError, "poll_reminder subject must be a Poll" unless poll.is_a?(Poll)

      recipients = explicit_users.active
      in_app_scope = poll.topic.members
                         .where("users.id": recipients.select(:id))
                         .where.not(id: notification.actor_id)
      chatbots = poll.group.chatbots
      user_recipients_by_channel(
        in_app_scope,
        email: poll.topic.email_enabled_members,
        push: poll.topic.push_enabled_members
      ).merge(
        "chatbot" => chatbots.where(id: notification.recipient_chatbot_ids)
                             .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind))
      )
    end
  end
end
