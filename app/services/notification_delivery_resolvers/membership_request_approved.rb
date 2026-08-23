module NotificationDeliveryResolvers
  class MembershipRequestApproved < NotificationDeliveryResolver
    def self.deduplication_key(membership, occurrence_key: nil)
      "membership_request_approved:membership_#{membership.id}"
    end

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
