module NotificationDeliveryRouters
  class NewCoordinator < NotificationDeliveryRouter
    handles :new_coordinator

    def recipients_by_channel
      membership = subject_model
      recipients(User.active.where(id: membership.user_id), volume: membership.group)
    end
  end
end
