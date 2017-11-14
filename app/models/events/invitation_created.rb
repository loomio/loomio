class Events::InvitationCreated < Event
  def self.publish!(invitation, actor)
    super invitation, user: actor, announcement: true
  end

  def poll
    eventable.group.invitation_target
  end

  def trigger!
    super
    eventable.mailer.delay(priority: 1).invitation_created(eventable, self)
    eventable.increment!(:send_count)
  end
end
