class Events::InvitationAccepted < Event
  include Events::NotifyUser

  def self.publish!(membership)
    create(kind: "invitation_accepted",
           eventable: membership).tap { |e| EventBus.broadcast('invitation_accepted_event', e) }
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
