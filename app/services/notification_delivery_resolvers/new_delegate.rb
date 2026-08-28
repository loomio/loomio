module NotificationDeliveryResolvers
  class NewDelegate < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject_model
      unless membership.is_a?(Membership)
        raise ArgumentError, "new_delegate subject must be a Membership"
      end

      email_scope = membership.email_enabled? ? User.all : User.none
      user_recipients_by_channel(
        User.active.where(id: membership.user_id),
        email: email_scope,
        push: membership.group.push_enabled_members
      )
    end
  end
end
