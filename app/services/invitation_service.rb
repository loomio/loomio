class InvitationService
  def self.resend(invitation:, actor:)
    actor.ability.authorize! :resend, invitation
    EventBus.broadcast 'invitation_resend', invitation, actor
    Events::InvitationResend.publish!(invitation)
  end

  def self.resend_ignored(send_count:, since:)
    Invitation.ignored(send_count, since).each do |invitation|
      Events::InvitationResend.publish!(invitation)
    end
  end
end
