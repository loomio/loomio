module NotificationDeliveryResolvers
  class InvitationAccepted < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject_model
      unless membership.is_a?(Membership)
        raise ArgumentError, "invitation_accepted subject must be a Membership"
      end

      user_recipients_by_channel(
        User.active.where(id: membership.inviter_id),
        email: User.none,
        push: membership.group.push_enabled_members
      )
    end
  end
end
