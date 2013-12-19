class CreateInvitation
  def self.to_start_group(args)
    args[:to_be_admin] = true
    args[:intent] = 'start_group'
    Invitation.create(args)
  end

  def self.to_join_group(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_group'
    Invitation.create(args)
  end

  def self.after_membership_request_approval(args)
    args[:to_be_admin] = false
    args[:intent] = 'join_group'
    Invitation.create(args)
  end

  def self.to_people_and_email_them(recipient_emails: nil,
                                    message: nil,
                                    group: nil,
                                    inviter: nil)
    recipient_emails.each do |recipient_email|
      invitation = to_join_group(recipient_email: recipient_email,
                                 group: group,
                                 inviter: inviter)
      InvitePeopleMailer.delay.to_join_group(invitation, inviter, message)
    end
    recipient_emails.size
  end
end
