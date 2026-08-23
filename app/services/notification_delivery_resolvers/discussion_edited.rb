module NotificationDeliveryResolvers
  class DiscussionEdited < NotificationDeliveryResolver
    def self.deduplication_key(discussion, occurrence_key: nil)
      raise ArgumentError, "discussion_edited occurrence_key is required" if occurrence_key.blank?

      "discussion_edited:discussion_#{discussion.id}:#{occurrence_key}"
    end

    private

    # Discussion edits notify only the explicitly selected audience. Mention
    # notifications are separate logical occurrences, so exclude users newly
    # mentioned by this edit from the edit email to avoid duplicate mail.
    def recipients_by_channel
      discussion = notification.subject
      unless discussion.is_a?(Discussion)
        raise ArgumentError, "discussion_edited subject must be a Discussion"
      end

      recipients = explicit_users.active
      {
        "in_app" => discussion.topic.volume_gte_quiet_members
                              .where("users.id": recipients.select(:id))
                              .where.not(id: notification.actor_id).to_a,
        "email" => discussion.topic.volume_gte_normal_members
                             .where("users.id": recipients.no_spam_complaints.select(:id))
                             .where.not(id: audience_ids("newly_mentioned_user_ids")).to_a,
        "chatbot" => (discussion.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids).to_a
      }
    end

    def audience_ids(key)
      Array(notification.audience_values[key]).map(&:to_i)
    end
  end
end
