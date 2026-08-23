module NotificationDeliveryResolvers
  class MembershipCreated < NotificationDeliveryResolver
    private

    def recipients_by_channel
      group = notification.subject
      unless group.is_a?(Group)
        raise ArgumentError, "membership_created subject must be a Group"
      end

      user_scope = explicit_users.active
      {
        "in_app" => group.volume_gte_quiet_members
                         .where("users.id": user_scope.select(:id))
                         .where.not(id: notification.actor_id).to_a,
        "email" => group.volume_gte_normal_members
                        .where("users.id": user_scope.no_spam_complaints.select(:id)).to_a
      }
    end
  end
end
