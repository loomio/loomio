module NotificationDeliveryRouters
  # Outcome creation and edits share recipient rules while retaining distinct
  # occurrence identities and notification kinds in their concrete routers.
  class OutcomeChange < NotificationDeliveryRouter
    subject_model_class Outcome

    # Outcome forms can include their actor, so the stored recipient IDs are
    # authoritative. A separate mention occurrence owns every channel for newly
    # mentioned users.
    def recipients_by_channel
      outcome = subject_model
      in_app_recipients = outcome.topic.members
                                           .where("users.id": user_recipients.active.select(:id))
                                           .where.not(id: audience_value_ids("newly_mentioned_user_ids"))
      recipients(
        in_app_recipients,
        volume: outcome.topic,
        chatbots: (outcome.group&.chatbots || Chatbot.none)
                    .where(id: notification.recipient_chatbot_ids)
      )
    end

  end
end
