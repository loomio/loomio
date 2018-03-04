class Events::InvitationCreated < Event
  def self.publish!(invitation, actor)
    create(kind: "invitation_created",
           user: actor,
           eventable: invitation,
           announcement: true,
           created_at: invitation.created_at).tap { |e| EventBus.broadcast('invitation_created_event', e) }
  end

  def trigger!
    super
    eventable.mailer.delay(priority: 1).invitation_created(eventable, self)
    eventable.increment!(:send_count)
  end
end
