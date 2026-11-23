module NotificationDeliveryRouters
  class InvitationAccepted < NotificationDeliveryRouter
    handles :invitation_accepted

    JOIN_VIA_LINK_NOTIFY_LIMIT = 10

    def recipients_by_channel
      membership = subject_model
      if membership.inviter_id.present?
        return recipients(User.active.where(id: membership.inviter_id))
      end

      # Shareable-link joins have no inviter. Notify active group admins using
      # their group notification settings for the first 10 joiners, then in-app only.
      group = membership.group
      admins = group.admins.active.where.not(id: membership.user_id)
      joined_count = group.memberships.active.accepted.where.not(user_id: group.creator_id).count
      return recipients(admins) if joined_count > JOIN_VIA_LINK_NOTIFY_LIMIT

      recipients(admins, volume: group)
    end
  end
end
