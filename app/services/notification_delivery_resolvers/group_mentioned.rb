module NotificationDeliveryResolvers
  class GroupMentioned < NotificationDeliveryResolver
    def self.deduplication_key(subject, occurrence_key: nil)
      if occurrence_key.blank?
        raise ArgumentError, "group_mentioned occurrence_key is required"
      end

      "group_mentioned:#{subject.class.base_class.name}_#{subject.id}:#{occurrence_key}"
    end

    private

    def recipients_by_channel
      memberships = Membership.active.accepted
                              .where(group_id: audience_ids("group_ids"))
                              .where.not(user_id: notification.actor_id)
                              .where.not(user_id: audience_ids("mentioned_user_ids"))
                              .where.not(user_id: audience_ids("already_notified_user_ids"))
      users = User.active.verified
      {
        "in_app" => users.where(id: memberships.app_notifications.select(:user_id)).to_a,
        "email" => users.no_spam_complaints
                        .where(id: memberships.email_notifications.select(:user_id)).to_a
      }
    end

    def audience_ids(key)
      Array(notification.audience_values[key]).map(&:to_i)
    end
  end
end
