class InvitationService

  def self.create_invite_to_start_group(args)
    args[:to_be_admin] = true
    args[:intent] = 'start_group'
    args[:invitable] = args[:group]
    args.delete(:group)
    Invitation.create!(args)
  end

  def self.create_invite_to_join_group(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_group'
    args[:invitable] = args[:group]
    args.delete(:group)
    Invitation.create!(args)
  end

  def self.invite_creator_to_group(group:, creator:)
    InvitePeopleMailer.delay(priority: 1).to_start_group(
      invitation: InvitationService.create_invite_to_start_group(
        group:           group,
        inviter:         User.helper_bot,
        recipient_email: creator.email,
        recipient_name:  creator.name
      )
    )
  end

  def self.invite_to_group(recipient_emails: nil,
                           message: nil,
                           group: nil,
                           inviter: nil)

    emails = (recipient_emails - group.members.pluck(:email)).take(100)

    recent_pending_invitations_count = group.pending_invitations.where("created_at > ?", 2.weeks.ago).count
    num_used = recent_pending_invitations_count + emails.length
    max_allowed = ENV.fetch('MAX_PENDING_INVITATIONS', 100).to_i + group.memberships_count

    raise "Too many pending invitations - group_id: #{group.id} #{group.name}" if num_used > max_allowed

    emails.map do |recipient_email|
      invitation = create_invite_to_join_group(recipient_email: recipient_email,
                                               group: group,
                                               message: message,
                                               inviter: inviter)

      InvitePeopleMailer.delay(priority: 1).to_join_group(invitation: invitation,
                                                          locale: I18n.locale)
      invitation
    end
  end

  def self.resend(invitation)
    return unless invitation.is_pending?
    InvitePeopleMailer.delay(priority: 1).to_join_group(invitation: invitation,
                                           locale: I18n.locale,
                                           subject_key: "email.resend_to_join_group.subject")
    invitation
  end

  def self.cancel(invitation:, actor:)
    actor.ability.authorize! :cancel, invitation
    invitation.cancel!(canceller: actor)
  end

  def self.shareable_invitation_for(group)
    if group.invitations.shareable.count == 0
      Invitation.create!(single_use: false,
                         intent: 'join_group',
                         invitable: group)
    end
    group.invitations.shareable.first
  end

  def self.redeem(invitation, user)
    if invitation.cancelled?
      raise Invitation::InvitationCancelled
    end

    if invitation.accepted?
      raise Invitation::InvitationAlreadyUsed
    end

    if invitation.single_use?
      invitation.accepted_at = DateTime.now
    end

    if invitation.to_be_admin?
      membership = invitation.group.add_admin!(user, invitation.inviter)
    else
      membership = invitation.group.add_member!(user, invitation.inviter)
    end
    invitation.save!
    Events::InvitationAccepted.publish!(membership)
  end

  def self.resend_ignored(send_count:, since:)
    Invitation.ignored(send_count, since).each { |invitation| resend invitation  }
  end
end
