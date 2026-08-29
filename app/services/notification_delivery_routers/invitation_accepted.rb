module NotificationDeliveryRouters
  class InvitationAccepted < NotificationDeliveryRouter
    def recipients_by_channel
      membership = subject_model
      recipients(User.active.where(id: membership.inviter_id))
    end
  end
end
