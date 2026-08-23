module NotificationDeliveryResolvers
  class PollClosingSoon < NotificationDeliveryResolver
    private

    def recipients_by_channel
      poll = notification.subject
      unless poll.is_a?(Poll)
        raise ArgumentError, "poll_closing_soon subject must be a Poll"
      end
      raw_recipients = case poll.notify_on_closing_soon
      when "undecided_voters" then poll.unmasked_undecided_voters
      when "voters" then poll.unmasked_voters
      else User.none
      end

      email_recipients = if poll.notify_on_closing_soon == "author"
        User.active.where(id: poll.author_id)
      else
        poll.topic.volume_gte_normal_members
            .where("users.id": raw_recipients.active.no_spam_complaints.select(:id))
      end

      {
        "in_app" => poll.topic.volume_gte_quiet_members
                        .where("users.id": raw_recipients.active.select(:id)).to_a,
        "email" => email_recipients.to_a,
        "chatbot" => (poll.group&.chatbots || Chatbot.none)
                           .where("? = ANY(chatbots.event_kinds)", notification.kind).to_a
      }
    end
  end
end
