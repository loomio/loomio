class InvitesUsersToGroup
  def self.invite!(args)
    recipient_emails = args[:recipient_emails]
    group = args[:group]
    inviter = args[:inviter]
    access_level = args[:access_level]
    recipient_emails.each do |recipient_email|
      invitation = Invitation.create!(:recipient_email => recipient_email,
                         :inviter => inviter,
                         :group => group,
                         :access_level => access_level)
      GroupInvitationMailer.send("invite_#{access_level}",
                                  :recipient_email => recipient_email,
                                  :group => group,
                                  :inviter => inviter,
                                  :token => invitation.token).deliver
    end
  end
end
