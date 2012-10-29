class InvitesUsersToGroup
  def self.invite!(args)
    recipient_emails = args[:recipient_emails]
    group = args[:group]
    inviter = args[:inviter]
    access_level = args[:access_level] ? args[:access_level] : 'member'
    recipient_emails.each do |recipient_email|
      Invitation.create!(:recipient_email => recipient_email,
                         :inviter => inviter,
                         :group => group,
                         :access_level => access_level)
      GroupInvitationMailer.invite_member(:recipient_email => recipient_email,
                                          :group => group,
                                          :inviter => inviter).deliver
    end
    
  end

end
