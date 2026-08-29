module NotificationDeliveryRouters
  class GroupMentioned < NotificationDeliveryRouter
    handles :group_mentioned

    # A group mention uses the mentioned memberships to select recipients and
    # determine email/push volume, independent of topic-level overrides.
    def recipients_by_channel
      memberships = Membership.active.accepted
                              .where(group_id: recipient_context_ids("group_ids"))
                              .where.not(user_id: notification.actor_id)
                              .where.not(user_id: recipient_context_ids("mentioned_user_ids"))
                              .where.not(user_id: recipient_context_ids("already_notified_user_ids"))
      users = User.active.verified.where(id: memberships.select(:user_id))
      recipients(users, volume: memberships)
    end
  end
end
