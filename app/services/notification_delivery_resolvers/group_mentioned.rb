module NotificationDeliveryResolvers
  class GroupMentioned < NotificationDeliveryResolver
    private

    # A group mention uses the mentioned memberships as both its audience and
    # its email/push volume context, independent of topic-level overrides.
    def recipients_by_channel
      memberships = Membership.active.accepted
                              .where(group_id: audience_ids("group_ids"))
                              .where.not(user_id: notification.actor_id)
                              .where.not(user_id: audience_ids("mentioned_user_ids"))
                              .where.not(user_id: audience_ids("already_notified_user_ids"))
      users = User.active.verified
      in_app_scope = users.where(id: memberships.select(:user_id))
      user_recipients_by_channel(
        in_app_scope,
        email: users.where(id: memberships.email_enabled.select(:user_id)),
        push: users.where(id: memberships.push_enabled.select(:user_id))
      )
    end

  end
end
