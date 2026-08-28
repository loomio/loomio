module NotificationDeliveryResolvers
  class PollEdited < NotificationDeliveryResolver
    private

    # Explicit recipients receive in-app and normal-volume email delivery.
    # Mentions are separate notifications and are excluded from the edit email.
    def recipients_by_channel
      poll = notification.subject_model
      raise ArgumentError, "poll_edited subject must be a Poll" unless poll.is_a?(Poll)

      explicit_scope = explicit_users.active
      email_members = if notification.recipient_message.present?
        poll.topic.email_normal_members
      else
        poll.topic.email_enabled_members
      end
      email_explicit = email_members
                         .where("users.id": explicit_scope.select(:id))
                         .where.not(id: audience_ids("newly_mentioned_user_ids"))
      {
        "in_app" => poll.topic.members
                        .where("users.id": explicit_scope.select(:id))
                        .where.not(id: notification.actor_id).to_a,
        "email" => email_explicit.to_a,
        "chatbot" => (poll.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids).to_a
      }
    end

    def audience_ids(key)
      Array(notification.audience_values[key]).map(&:to_i)
    end
  end
end
