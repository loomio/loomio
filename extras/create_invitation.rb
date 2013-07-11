class CreateInvitation
  def self.to_start_group(args)
    args[:to_be_admin] = true
    args[:intent] = 'start_group'
    Invitation.create(args)
  end

  # example of use:
  #   args = { recipient_email: recipient_email, inviter: @user, group: @group }
  #   CreateInvitation.to_join_group(args)
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

  def self.to_people_and_email_them(invite_people, args)
    invite_people.parsed_recipients.each do |recipient_email|
      invitation = to_join_group(recipient_email: recipient_email,
                                 group: args[:group],
                                 inviter: args[:inviter])
      InvitePeopleMailer.delay.to_join_group(invitation, args[:inviter].email, invite_people.message_body)
    end
    invite_people.parsed_recipients.size
  end
end
