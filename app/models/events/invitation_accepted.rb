class Events::InvitationAccepted < Event
  def self.publish!(membership)
    create!(kind: "invitation_accepted",
            eventable: membership)
  end

  def membership
    eventable
  end
end
