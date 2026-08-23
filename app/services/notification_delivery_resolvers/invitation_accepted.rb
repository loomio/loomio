module NotificationDeliveryResolvers
  class InvitationAccepted < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject
      unless membership.is_a?(Membership)
        raise ArgumentError, "invitation_accepted subject must be a Membership"
      end

      {
        "in_app" => User.active.where(id: membership.inviter_id).to_a
      }
    end
  end
end
