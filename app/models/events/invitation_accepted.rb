class Events::InvitationAccepted < Event
  include Events::Notify::InApp
  include Events::LiveUpdate

  def self.publish!(membership)
    super membership, user: membership.user
  end

  def notify_clients!
    ActionCable.server.broadcast eventable.message_channel, action: :accepted
  end

  private

  def notification_recipients
    User.where(id: eventable.inviter_id)
  end

  def notification_actor
    eventable&.user
  end

  def notification_url
    polymorphic_url(eventable.group)
  end
end
