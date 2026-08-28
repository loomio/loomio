module NotificationDeliveryResolvers
  class PollClosingSoon < NotificationDeliveryResolver
    private

    # Author and voter modes choose different audiences, but every selected user
    # receives the same in-app occurrence with email and push filtered by their
    # effective topic settings.
    def recipients_by_channel
      poll = notification.subject_model
      unless poll.is_a?(Poll)
        raise ArgumentError, "poll_closing_soon subject must be a Poll"
      end
      raw_recipients = case poll.notify_on_closing_soon
      when "author" then User.active.where(id: poll.author_id)
      when "undecided_voters" then poll.unmasked_undecided_voters.active
      when "voters" then poll.unmasked_voters.active
      else User.none
      end
      recipient_scope = poll.topic.members
                            .where("users.id": raw_recipients.select(:id))

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
