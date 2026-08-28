module NotificationDeliveryResolvers
  class UserMentioned < NotificationDeliveryResolver
    private

    def recipients_by_channel
      recipients = explicit_users.active.verified
      email_candidates = recipients.where(email_when_mentioned: true)
      email_users = if (topic = notification_topic)
        topic.email_enabled_members.where(id: email_candidates.select(:id))
      elsif (group = notification_group)
        group.email_enabled_members.where(id: email_candidates.select(:id))
      else
        email_candidates.where(
          volume_email_default: User.volume_email_defaults.values_at("normal", "loud")
        )
      end
      push_scope = if recipients.none?
        User.none
      elsif (topic = notification_topic)
        topic.push_enabled_members
      elsif (group = notification_group)
        group.push_enabled_members
      else
        User.where(volume_push_default: User.volume_push_defaults.values_at("normal", "loud"))
      end

      user_recipients_by_channel(recipients, email: email_users, push: push_scope)
    end
  end
end
