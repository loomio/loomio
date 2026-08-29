module NotificationDeliveryRouters
  class MembershipRequestApproved < NotificationDeliveryRouter
    def recipients_by_channel
      membership = subject_model
      recipients(User.active.where(id: membership.user_id))
    end
  end
end
