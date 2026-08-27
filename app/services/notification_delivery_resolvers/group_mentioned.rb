module NotificationDeliveryResolvers
  class GroupMentioned < NotificationDeliveryResolver
    private

    def recipients_by_channel
      memberships = Membership.active.accepted
                              .where(group_id: audience_ids("group_ids"))
                              .where.not(user_id: notification.actor_id)
                              .where.not(user_id: audience_ids("mentioned_user_ids"))
                              .where.not(user_id: audience_ids("already_notified_user_ids"))
      users = User.active.verified
      {
        "in_app" => users.where(id: memberships.select(:user_id)).to_a,
        "email" => users.no_spam_complaints
                        .where(id: memberships.email_notifications.select(:user_id)).to_a
      }
    end

    def audience_ids(key)
      Array(notification.audience_values[key]).map(&:to_i)
    end
  end
end
