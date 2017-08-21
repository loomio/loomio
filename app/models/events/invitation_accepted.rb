class Events::InvitationAccepted < Event
  include Events::Notify::InApp

  def self.publish!(membership)
    super(membership, user: membership.user)
  end

  private

  def notification_recipients
    User.where(id: eventable.inviter_id)
  end

  def notification_actor
    eventable&.user
  end

  def notification_url
    group_memberships_username_url(eventable.group, eventable.user.username) if eventable
  end
end
