module NotificationDeliveryResolvers
  class PollExpired < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject_model
      unless poll.is_a?(Poll)
        raise ArgumentError, "poll_expired subject must be a Poll"
      end
      author = User.where(id: poll.author_id)
      email_author = poll.topic.email_notification_members.where("users.id": author.active.select(:id))
      {
        "in_app" => author.to_a,
        "email" => email_author.to_a,
        "chatbot" => (poll.group&.chatbots || Chatbot.none)
                           .where("? = ANY(chatbots.event_kinds)", notification.kind).to_a
      }
    end
  end
end
