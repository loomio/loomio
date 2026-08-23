module NotificationDeliveryResolvers
  class MembershipResent < NotificationDeliveryResolver
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
