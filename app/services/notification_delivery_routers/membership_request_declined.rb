module NotificationDeliveryRouters
  class MembershipRequestDeclined < NotificationDeliveryRouter
    handles :membership_request_declined

    def recipients_by_channel
      users = User.active.where(id: subject_model.requestor_id)
      recipients(users).merge("email" => users)
    end
  end
end
