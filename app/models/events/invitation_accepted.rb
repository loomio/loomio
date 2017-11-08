class Events::InvitationAccepted < Event
  include Events::Notify::InApp

  def self.publish!(membership)
    super(membership, user: membership.user)
  end

  private

  def notification_recipients
    User.where(id: eventable.inviter_id)
  end

  def notification_params
    super.merge(actor: eventable.user, url: notification_url)
  end

  def notification_url
    case eventable.group
    when FormalGroup then group_memberships_username_url(eventable.group, eventable.user.username)
    when GuestGroup  then polymorphic_url(eventable.group.invitation_target)
    end
  end
end
