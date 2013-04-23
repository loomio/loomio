class InvitePeopleMailer < ActionMailer::Base
  default from: "from@example.com"

  def invitation_email(invitation, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email, 
         subject: "#{@invitation.inviter.name} invites you to join #{@invitation.group_name} on Loomio"
  end
end
