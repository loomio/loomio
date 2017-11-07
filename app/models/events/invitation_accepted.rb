class Events::InvitationAccepted < Event
  include Events::Notify::InApp

  def self.publish!(membership)
    create(kind: "invitation_accepted",
           user_id: membership.user_id,
           eventable: membership,
           created_at: membership.created_at).tap { |e| EventBus.broadcast('invitation_accepted_event', e) }
  end

  private

  def notification_recipients
    User.where(id: eventable.inviter_id)
  end

  def notification_actor
    eventable&.user
  end

  def notification_url
    case eventable.group
    when FormalGroup then group_memberships_username_url(eventable.group, eventable.user.username)
    when GuestGroup  then polymorphic_url(eventable.group.invitation_target)
    end
  end
end
