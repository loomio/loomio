class Events::InvitationAccepted < Event
  def self.publish!(membership)
    create(kind: "invitation_accepted",
           eventable: membership).tap { |e| EventBus.broadcast('invitation_accepted_event', e, e.eventable.inviter) }
  end

  def membership
    eventable
  end
end
