module NotificationDeliveryResolvers
  class NewDiscussion < NotificationDeliveryResolver
    private

    # Loud subscribers receive the topic publication email, while this
    # notification carries the explicit user and chatbot audience.
    def recipients_by_channel
      discussion = notification.subject_model
      unless discussion.is_a?(Discussion)
        raise ArgumentError, "new_discussion subject must be a Discussion"
      end

      explicit_scope = explicit_users.active
      email_explicit = discussion.topic.volume_gte_normal_members
                                 .where("users.id": explicit_scope.no_spam_complaints.select(:id))
                                 .where.not(id: discussion.topic.volume_loud_members.select(:id))
                                 .where.not(id: audience_ids("newly_mentioned_user_ids"))

      {
        "in_app" => discussion.topic.app_notification_members
                              .where("users.id": explicit_scope.select(:id))
                              .where.not(id: discussion.author_id).to_a,
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
