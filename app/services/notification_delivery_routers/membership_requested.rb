module NotificationDeliveryRouters
  class MembershipRequested < NotificationDeliveryRouter
    subject_model_class MembershipRequest

    def translation_values
      {
        name: subject_model.requestor&.name || subject_model.name,
        title: subject_model.group.full_name
      }
    end

    def recipients_by_channel
      membership_request = subject_model
      recipients(membership_request.admins.active, volume: membership_request.group)
    end
  end
end
