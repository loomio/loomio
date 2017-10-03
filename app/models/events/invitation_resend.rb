class Events::InvitationResend < Event
  def self.publish!(invitation)
    create(kind: "invitation_resend",
           user: invitation.inviter,
           eventable: invitation,
           announcement: true,
           created_at: invitation.created_at).tap { |e| EventBus.broadcast('invitation_resend_event', e) }
  end

  def poll
    eventable.group.invitation_target
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
