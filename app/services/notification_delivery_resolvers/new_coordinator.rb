module NotificationDeliveryResolvers
  class NewCoordinator < NotificationDeliveryResolver
    def self.deduplication_key(membership, occurrence_key: nil)
      "new_coordinator:membership_#{membership.id}:#{membership.updated_at.iso8601(6)}"
    end

    private

    def recipients_by_channel
      membership = notification.subject
      unless membership.is_a?(Membership)
        raise ArgumentError, "new_coordinator subject must be a Membership"
      end

      { "in_app" => User.active.where(id: membership.user_id).to_a }
    end
  end
end
