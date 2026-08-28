module NotificationDeliveryRouters
  class InvitationAccepted < NotificationDeliveryRouter
    subject_model_class Membership

    def recipients_by_channel
      membership = subject_model
      recipients(User.active.where(id: membership.inviter_id))
    end
  end
end
