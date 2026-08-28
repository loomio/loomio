module NotificationDeliveryResolvers
  class DiscussionEdited < NotificationDeliveryResolver
    private

    # Discussion edits notify only the explicitly selected audience. Mention
    # notifications are separate logical occurrences, so exclude users newly
    # mentioned by this edit from the edit email to avoid duplicate mail.
    def recipients_by_channel
      discussion = notification.subject_model
      unless discussion.is_a?(Discussion)
        raise ArgumentError, "discussion_edited subject must be a Discussion"
      end

      recipients = explicit_users.active
      email_members = if notification.recipient_message.present?
        discussion.topic.email_normal_members
      else
        discussion.topic.email_enabled_members
      end
      email_explicit = email_members
                         .where("users.id": recipients.select(:id))
                         .where.not(id: audience_ids("newly_mentioned_user_ids"))
      {
        "in_app" => discussion.topic.members
                              .where("users.id": recipients.select(:id))
                              .where.not(id: notification.actor_id).to_a,
        "email" => email_explicit.to_a,
        "chatbot" => (discussion.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids).to_a
      }
    end

    def audience_ids(key)
      Array(notification.audience_values[key]).map(&:to_i)
    end
  end
end
