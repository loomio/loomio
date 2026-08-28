module NotificationDeliveryResolvers
  class OutcomeReviewDue < NotificationDeliveryResolver
    private

    def recipients_by_channel
      outcome = notification.subject_model
      unless outcome.is_a?(Outcome)
        raise ArgumentError, "outcome_review_due subject must be an Outcome"
      end

      author_scope = User.active.where(id: outcome.author_id)
      topic = outcome.poll.topic
      in_app_scope = topic.members.where("users.id": author_scope.select(:id))
      user_recipients_by_channel(
        in_app_scope,
        email: topic.email_enabled_members,
        push: topic.push_enabled_members
      ).merge(
        "chatbot" => outcome.group.chatbots
                            .where("? = ANY(chatbots.event_kinds)", notification.kind)
      )
    end
  end
end
