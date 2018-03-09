class InvitationService
  def self.create(invitation: , actor: )
    actor.ability.authorize!(:create, invitation)
    invitation.inviter = actor

    return false unless invitation.valid?

    invitation.save!

    EventBus.broadcast('invitation_create', invitation, actor)
    Events::InvitationCreated.publish!(invitation, actor)
  end

  def self.create_invite_to_join_group(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_group'
    Invitation.create!(args)
  end

  def self.invite_to_group(recipient_emails: nil,
                           message: nil,
                           group: nil,
                           inviter: nil)

    emails = (recipient_emails - group.members.pluck(:email)).take(100)
    raise Invitation::AllInvitesAreMembers.new if emails.empty?

    recent_pending_invitations_count   = group.invitations.pending.where("created_at > ?", 2.weeks.ago).count
    recent_cancelled_invitations_count = group.invitations.cancelled.where("created_at > ?", 2.weeks.ago).count

    recent_pending   = recent_pending_invitations_count + emails.length
    recent_cancelled = recent_cancelled_invitations_count + emails.length

    raise Invitation::TooManyPending.new   if recent_pending   > group.pending_invitation_limit
    raise Invitation::TooManyCancelled.new if recent_cancelled > group.pending_invitation_limit

    emails.map do |recipient_email|
      invitation = create_invite_to_join_group(recipient_email: recipient_email,
                                               group: group,
                                               message: message,
                                               inviter: inviter)
      Events::InvitationCreated.publish!(invitation, inviter)
      invitation
    end
  end

  def self.resend(invitation:, actor:)
    actor.ability.authorize! :resend, invitation
    EventBus.broadcast 'invitation_resend', invitation, actor
    Events::InvitationResend.publish!(invitation)
  end

  def self.cancel(invitation:, actor:)
    actor.ability.authorize! :cancel, invitation
    invitation.cancel!(canceller: actor)
  end

  def self.redeem(invitation, user)
    return true if invitation.group.members.include?(user)
    raise Invitation::InvitationCancelled                   if invitation.cancelled?
    raise Invitation::InvitationAlreadyUsed.new(invitation) if invitation.accepted?
    invitation.accepted_at = DateTime.now                   if invitation.single_use?

    membership = invitation.group.add_member!(user, invitation: invitation)
    invitation.save!
    Events::InvitationAccepted.publish!(membership)
  end

  def self.resend_ignored(send_count:, since:)
    Invitation.ignored(send_count, since).each do |invitation|
      Events::InvitationResend.publish!(invitation)
    end
  end
end
