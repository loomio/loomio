module NotificationDeliveryResolvers
  class MembershipRequestApproved < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject
      unless membership.is_a?(Membership)
        raise ArgumentError, "membership_request_approved subject must be a Membership"
      end

      recipient = User.active.where(id: membership.user_id).to_a
      {
        "in_app" => recipient,
        "email" => recipient
      }
    end
  end
end
