class Events::InvitationCreated < Event
  def self.bulk_publish!(invitations, inviter)
    super invitations, user: inviter
  end

  def trigger!
    super
    eventable.mailer.delay(queue: :invitation_emails).invitation_created(eventable, self)
    eventable.increment!(:send_count)
  end
end
