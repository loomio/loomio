module NotificationDeliveryResolvers
  class UserAddedToGroup < NotificationDeliveryResolver
    def self.deduplication_key(membership, occurrence_key: nil)
      "user_added_to_group:membership_#{membership.id}:#{membership.updated_at.iso8601(6)}"
    end

    private

    def recipients_by_channel
      membership = notification.subject
      unless membership.is_a?(Membership)
        raise ArgumentError, "user_added_to_group subject must be a Membership"
      end

      recipient = User.active.where(id: membership.user_id)
      {
        "in_app" => recipient.to_a,
        "email" => recipient.no_spam_complaints.to_a
      }
    end
  end
end
