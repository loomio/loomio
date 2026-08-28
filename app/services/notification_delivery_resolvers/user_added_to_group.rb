module NotificationDeliveryResolvers
  class UserAddedToGroup < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject_model
      unless membership.is_a?(Membership)
        raise ArgumentError, "user_added_to_group subject must be a Membership"
      end

      user_recipients_by_channel(
        User.active.where(id: membership.user_id),
        email: User.all,
        push: membership.group.push_enabled_members
      )
    end
  end
end
