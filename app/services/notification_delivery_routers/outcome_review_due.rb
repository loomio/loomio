module NotificationDeliveryRouters
  class OutcomeReviewDue < NotificationDeliveryRouter
    handles :outcome_review_due

    def recipients_by_channel
      outcome = subject_model
      author_scope = User.active.where(id: outcome.author_id)
      topic = outcome.poll.topic
      users = topic.members.where("users.id": author_scope.select(:id))
      recipients(users, volume: topic)
    end
  end
end
