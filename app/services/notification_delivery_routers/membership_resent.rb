module NotificationDeliveryRouters
  class MembershipResent < NotificationDeliveryRouter
    def recipients_by_channel
      membership = subject_model
      transactional_email_only(
        email_recipients: User.active.where(id: membership.user_id)
      )
    end
  end
end
