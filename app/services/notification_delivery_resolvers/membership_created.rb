module NotificationDeliveryResolvers
  class MembershipCreated < NotificationDeliveryResolver
    def self.deduplication_key(group, occurrence_key: nil)
      if occurrence_key.blank?
        raise ArgumentError, "membership_created occurrence_key is required"
      end

      "membership_created:group_#{group.id}:#{occurrence_key}"
    end

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
