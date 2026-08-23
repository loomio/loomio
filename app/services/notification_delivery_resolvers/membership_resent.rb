module NotificationDeliveryResolvers
  class MembershipResent < NotificationDeliveryResolver
    def self.deduplication_key(membership, occurrence_key: nil)
      if occurrence_key.blank?
        raise ArgumentError, "membership_resent occurrence_key is required"
      end

      "membership_resent:membership_#{membership.id}:#{occurrence_key}"
    end

    private

    def recipients_by_channel
      membership = notification.subject
      unless membership.is_a?(Membership)
        raise ArgumentError, "membership_resent subject must be a Membership"
      end

      {
        "email" => User.active.no_spam_complaints.where(id: membership.user_id).to_a
      }
    end
  end
end
