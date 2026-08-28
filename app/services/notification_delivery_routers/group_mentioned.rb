module NotificationDeliveryRouters
  class GroupMentioned < NotificationDeliveryRouter
    subject_model_class HasMentions

    # A group mention uses the mentioned memberships to select recipients and
    # determine email/push volume, independent of topic-level overrides.
    def recipients_by_channel
      memberships = Membership.active.accepted
                              .where(group_id: audience_value_ids("group_ids"))
                              .where.not(user_id: notification.actor_id)
                              .where.not(user_id: audience_value_ids("mentioned_user_ids"))
                              .where.not(user_id: audience_value_ids("already_notified_user_ids"))
      in_app_recipients = User.active.verified.where(id: memberships.select(:user_id))
      recipients(in_app_recipients, volume: memberships)
    end

  end
end
