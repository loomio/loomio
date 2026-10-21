# Invitations keep their membership identity when sent again. Select occurrences
# for this group and recipient, including email-only resends, without exposing the
# other people named in a batch invitation.
class MembershipNotificationHistory
  def self.for(membership)
    invitations = Notification.where(kind: 'membership_created', subject: membership.group)
      .where('recipient_user_ids @> ARRAY[?]::integer[]', membership.user_id)
    resends = Notification.where(kind: 'membership_resent', subject: membership)
    # Keep each polymorphic subject lookup on its own index path. OR across
    # Group and Membership subjects can otherwise scan all notifications.
    Notification.from("(#{invitations.to_sql} UNION ALL #{resends.to_sql}) AS notifications")
      .order(created_at: :desc, id: :desc)
  end
end
