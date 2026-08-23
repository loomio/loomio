module NotificationDeliveryResolvers
  class DiscussionAnnounced < NotificationDeliveryResolver
    def self.deduplication_key(discussion, occurrence_key: nil)
      if occurrence_key.blank?
        raise ArgumentError, "discussion_announced occurrence_key is required"
      end

      "discussion_announced:discussion_#{discussion.id}:#{occurrence_key}"
    end

    private

    def recipients_by_channel
      discussion = notification.subject
      unless discussion.is_a?(Discussion)
        raise ArgumentError, "discussion_announced subject must be a Discussion"
      end

      user_scope = explicit_users.active
      chatbots = discussion.group&.chatbots || Chatbot.none
      {
        "in_app" => discussion.topic.volume_gte_quiet_members
                              .where("users.id": user_scope.select(:id))
                              .where.not(id: notification.actor_id).to_a,
        "email" => discussion.topic.volume_gte_normal_members
                             .where("users.id": user_scope.no_spam_complaints.select(:id)).to_a,
        "chatbot" => chatbots.where(id: notification.recipient_chatbot_ids)
                             .or(chatbots.where("? = ANY(chatbots.event_kinds)", notification.kind)).to_a
      }
    end
  end
end
