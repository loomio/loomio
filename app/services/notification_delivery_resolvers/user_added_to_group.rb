module NotificationDeliveryResolvers
  class UserAddedToGroup < NotificationDeliveryResolver
    private

    def recipients_by_channel
      membership = notification.subject_model
      unless membership.is_a?(Membership)
        raise ArgumentError, "user_added_to_group subject must be a Membership"
      end

      recipient = User.active.where(id: membership.user_id)
      {
        "in_app" => recipient.to_a,
        "email" => recipient.to_a
      }
    end
  end
end
