module NotificationDeliveryResolvers
  class PollExpired < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject_model
      unless poll.is_a?(Poll)
        raise ArgumentError, "poll_expired subject must be a Poll"
      end
      recipient_scope = poll.topic.members
                            .where("users.id": User.active.where(id: poll.author_id).select(:id))
      user_recipients_by_channel(
        recipient_scope,
        email: poll.topic.email_enabled_members,
        push: poll.topic.push_enabled_members
      ).merge(
        "chatbot" => (poll.group&.chatbots || Chatbot.none)
                           .where("? = ANY(chatbots.event_kinds)", notification.kind)
      )
    end
  end
end
