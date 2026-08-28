module NotificationDeliveryResolvers
  class NewDiscussion < NotificationDeliveryResolver
    private

    # Loud subscribers receive the topic publication email, while this
    # notification carries the explicit in-app, email, and chatbot audience.
    # The base resolver derives directed push from the in-app recipients.
    def recipients_by_channel
      discussion = notification.subject_model
      unless discussion.is_a?(Discussion)
        raise ArgumentError, "new_discussion subject must be a Discussion"
      end

      explicit_scope = explicit_users.active
      email_explicit = discussion.topic.email_notification_members
                                 .where("users.id": explicit_scope.no_spam_complaints.select(:id))
                                 .where.not(id: discussion.topic.email_loud_members.select(:id))
                                 .where.not(id: audience_ids("newly_mentioned_user_ids"))

      {
        "in_app" => discussion.topic.members
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
