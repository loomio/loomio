class InvitePeopleMailer < ActionMailer::Base
  def to_start_group(invitation, sender_email, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email, 
         from: 'contact@loomio.org',
         reply_to: sender_email,
         subject: "Your Loomio group: #{@invitation.group_name} has been approved!"
  end

  def to_join_group(invitation, sender_email, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email, 
         from: 'contact@loomio.org',
         reply_to: sender_email,
         subject: "#{@invitation.inviter.name} has invited you to join #{@invitation.group_name} on Loomio"
  end
end
