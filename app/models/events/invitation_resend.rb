class Events::InvitationResend < Event
  def self.publish!(invitation)
    super invitation, user: invitation.inviter, announcement: true
  end

  def trigger!
    super
    resend!
  end

  private

  def resend!
    eventable.mailer.delay(priority: 1).invitation_resend(eventable, self)
    eventable.increment!(:send_count)
    eventable.save
  end
  handle_asynchronously :resend!
end
