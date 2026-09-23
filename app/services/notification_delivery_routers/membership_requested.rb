module NotificationDeliveryRouters
  class MembershipRequested < NotificationDeliveryRouter
    handles :membership_requested

    def translation_values
      {
        name: subject_model.requestor&.name.presence ||
              subject_model.name.presence ||
              subject_model.requestor&.email ||
              subject_model.email,
        title: subject_model.group.full_name
      }
    end

    def recipients_by_channel
      membership_request = subject_model
      recipients(membership_request.admins.active, volume: membership_request.group)
    end
  end
end
