module NotificationDeliveryRouters
  class PollClosingSoon < NotificationDeliveryRouter
    # Author and voter modes choose different recipients, but every selected user
    # receives the same in-app occurrence with email and push filtered by their
    # effective topic settings.
    def recipients_by_channel
      poll = subject_model
      selected_recipients = case poll.notify_on_closing_soon
      when "author" then User.active.where(id: poll.author_id)
      when "undecided_voters" then poll.unmasked_undecided_voters.active
      when "voters" then poll.unmasked_voters.active
      else User.none
      end
      users = poll.topic.members
              .where("users.id": selected_recipients.select(:id))

      recipients(
        users,
        volume: poll.topic,
        chatbots: (poll.group&.chatbots || Chatbot.none)
                    .where("? = ANY(chatbots.event_kinds)", notification.kind)
      )
    end
  end
end
