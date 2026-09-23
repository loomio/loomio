module NotificationDeliveryRouters
  # Outcome announcements, creation, and edits use their selected recipients.
  # Forms can include the actor, and a separate mention occurrence owns every
  # channel for newly mentioned users.
  class OutcomeEvent < NotificationDeliveryRouter
    handles :outcome_announced, :outcome_created, :outcome_updated

    def recipients_by_channel
      outcome = subject_model
      users = outcome.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: recipient_context_ids("newly_mentioned_user_ids"))
      recipients(users, volume: outcome.topic)
    end
  end
end
