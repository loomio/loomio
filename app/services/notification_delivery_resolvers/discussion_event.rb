module NotificationDeliveryResolvers
  # Discussion creation, edits, and announcements share one directed-delivery
  # policy. The actor is excluded, and a separate mention occurrence owns every
  # channel for newly mentioned users. Announcements have no new mentions, so
  # their snapshotted exclusion is empty.
  class DiscussionEvent < NotificationDeliveryResolver
    private

    def recipients_by_channel
      discussion = notification.subject_model
      unless discussion.is_a?(::Discussion)
        raise ArgumentError, "discussion notification subject must be a Discussion"
      end

      recipient_scope = discussion.topic.members
                                  .where("users.id": explicit_users.active.select(:id))
                                  .where.not(id: notification.actor_id)
                                  .where.not(id: audience_ids("newly_mentioned_user_ids"))

      user_recipients_by_channel(
        recipient_scope,
        email: discussion.topic.email_enabled_members,
        push: discussion.topic.push_enabled_members
      ).merge(
        "chatbot" => (discussion.group&.chatbots || Chatbot.none)
                       .where(id: notification.recipient_chatbot_ids)
      )
    end
  end
end
