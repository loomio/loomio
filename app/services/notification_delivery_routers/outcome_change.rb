module NotificationDeliveryRouters
  # Outcome creation and edits share recipient rules while retaining distinct
  # occurrence identities and notification kinds in their concrete routers.
  class OutcomeChange < NotificationDeliveryRouter
    handles :outcome_created, :outcome_updated

    # Outcome forms can include their actor, so the stored recipient IDs are
    # authoritative. A separate mention occurrence owns every channel for newly
    # mentioned users.
    def recipients_by_channel
      outcome = subject_model
      users = outcome.topic.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: recipient_context_ids("newly_mentioned_user_ids"))
      recipients(users, volume: outcome.topic)
    end
  end
end
