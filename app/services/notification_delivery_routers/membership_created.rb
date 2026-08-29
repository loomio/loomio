module NotificationDeliveryRouters
  class MembershipCreated < NotificationDeliveryRouter
    subject_model_class Group

    def recipients_by_channel
      group = subject_model
      users = group.members
              .where("users.id": user_recipients.active.select(:id))
              .where.not(id: notification.actor_id)
      recipients(users, volume: group)
    end
  end
end
