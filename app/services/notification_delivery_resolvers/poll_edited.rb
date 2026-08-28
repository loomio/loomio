module NotificationDeliveryResolvers
  class PollEdited < NotificationDeliveryResolver
    private

    # Poll edits notify only explicitly selected users other than the actor. A
    # separate mention occurrence owns every channel for newly mentioned users.
    def recipients_by_channel
      poll = notification.subject_model
      raise ArgumentError, "poll_edited subject must be a Poll" unless poll.is_a?(Poll)

      explicit_scope = explicit_users.active

      recipient_scope = poll.topic.members
                            .where("users.id": explicit_scope.select(:id))
                            .where.not(id: notification.actor_id)
                            .where.not(id: audience_ids("newly_mentioned_user_ids"))
      user_recipients_by_channel(
        recipient_scope,
        email: poll.topic.email_enabled_members,
        push: poll.topic.push_enabled_members
      ).merge(
        "chatbot" => (poll.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids)
      )
    end

  end
end
