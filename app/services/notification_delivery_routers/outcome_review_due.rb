module NotificationDeliveryRouters
  class OutcomeReviewDue < NotificationDeliveryRouter
    subject_model_class Outcome

    def recipients_by_channel
      outcome = subject_model
      author_scope = User.active.where(id: outcome.author_id)
      topic = outcome.poll.topic
      in_app_recipients = topic.members.where("users.id": author_scope.select(:id))
      recipients(
        in_app_recipients,
        volume: topic,
        chatbots: outcome.group.chatbots
                         .where("? = ANY(chatbots.event_kinds)", notification.kind)
      )
    end
  end
end
