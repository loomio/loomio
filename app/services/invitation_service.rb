class InvitationService

  def self.create_invite_to_start_group(args)
    args[:to_be_admin] = true
    args[:intent] = 'start_group'
    args[:invitable] = args[:group]
    args.delete(:group)
    Invitation.create(args)
  end

  def self.create_invite_to_join_group(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_group'
    args[:invitable] = args[:group]
    args.delete(:group)
    Invitation.create(args)
  end

  def self.create_invite_to_join_discussion(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_discussion'
    args[:invitable] = args[:discussion]
    args.delete(:discussion)
    Invitation.create(args)
  end

  def self.invite_to_group(recipient_emails: nil,
                           message: nil,
                           group: nil,
                           inviter: nil)
    recipient_emails.each do |recipient_email|
      invitation = create_invite_to_join_group(recipient_email: recipient_email,
                                               group: group,
                                               inviter: inviter)
      InvitePeopleMailer.delay.to_join_group(invitation, inviter, message)
    end
  end

  def self.invite_to_discussion(recipient_emails: nil,
                                message: nil,
                                discussion: nil,
                                inviter: nil)
    recipient_emails.each do |recipient_email|
      invitation = create_invite_to_join_discussion(recipient_email: recipient_email,
                                                    discussion: discussion,
                                                    inviter: inviter)
      InvitePeopleMailer.delay.to_join_discussion(invitation, inviter, message)
    end
  end
end
