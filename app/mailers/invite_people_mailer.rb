class InvitePeopleMailer < ActionMailer::Base
  def to_start_group(invitation, sender_email, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email, 
         from: sender_email,
         subject: "Approved! Set up your Loomio group: #{@invitation.group_name}"
  end

  def to_join_group(invitation, sender_email, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email, 
         from: sender_email,
         subject: "#{@invitation.inviter.name} invites you to join #{@invitation.group_name} on Loomio"
  end
end
