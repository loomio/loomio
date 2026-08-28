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
      {
        "in_app" => topic.members.where("users.id": author_scope.select(:id)).to_a,
        "email" => topic.email_notification_members
                        .where("users.id": author_scope.no_spam_complaints.select(:id)).to_a,
        "chatbot" => outcome.group.chatbots
                            .where("? = ANY(chatbots.event_kinds)", notification.kind).to_a
      }
    end
  end
end
