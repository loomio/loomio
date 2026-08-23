module NotificationDeliveryResolvers
  class InvitationAccepted < NotificationDeliveryResolver
    def self.deduplication_key(membership, occurrence_key: nil)
      "invitation_accepted:membership_#{membership.id}"
    end

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
