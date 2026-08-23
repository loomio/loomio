module NotificationDeliveryResolvers
  class NewCoordinator < NotificationDeliveryResolver
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
