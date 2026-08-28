module NotificationDeliveryResolvers
  class MembershipCreated < NotificationDeliveryResolver
    private

    def recipients_by_channel
      group = notification.subject_model
      unless group.is_a?(Group)
        raise ArgumentError, "membership_created subject must be a Group"
      end

      user_scope = explicit_users.active
      {
        "in_app" => group.members
                         .where("users.id": user_scope.select(:id))
                         .where.not(id: notification.actor_id).to_a,
        "email" => group.email_notification_members
                        .where("users.id": user_scope.no_spam_complaints.select(:id)).to_a
      }
    end
  end
end
