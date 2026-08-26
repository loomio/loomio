module NotificationDeliveryResolvers
  class NewDelegate < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject_model
      unless membership.is_a?(Membership)
        raise ArgumentError, "new_delegate subject must be a Membership"
      end

      recipient = User.active.where(id: membership.user_id)
      email_recipient = if membership.volume_is_normal_or_loud?
        recipient.no_spam_complaints.to_a
      else
        []
      end

      {
        "in_app" => recipient.to_a,
        "email" => email_recipient
      }
    end
  end
end
