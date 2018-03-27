class Events::InvitationAccepted < Event
  include Events::Notify::InApp
  include Events::LiveUpdate

  def self.publish!(membership)
    super membership, user: membership.user
  end

  def notify_clients!
    if eventable.invitation&.email == eventable.user.email
      ActionCable.server.broadcast eventable.invitation.message_channel, action: :accepted
    end
  end

  private

  def notification_recipients
    User.where(id: eventable.inviter_id)
  end

  def notification_actor
    eventable&.user
  end

  def notification_url
    if eventable.group.is_a?(FormalGroup)
      group_memberships_username_url(eventable.group, eventable.user.username)
    else
      polymorphic_url(eventable.target_model)
    end
  end
end
