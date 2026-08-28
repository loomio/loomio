module NotificationDeliveryResolvers
  class MembershipCreated < NotificationDeliveryResolver
    private

    def recipients_by_channel
      group = notification.subject_model
      unless group.is_a?(Group)
        raise ArgumentError, "membership_created subject must be a Group"
      end

      user_scope = explicit_users.active
      in_app_scope = group.members
                          .where("users.id": user_scope.select(:id))
                          .where.not(id: notification.actor_id)
      user_recipients_by_channel(
        in_app_scope,
        email: group.email_enabled_members,
        push: group.push_enabled_members
      )
    end
  end
end
