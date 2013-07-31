class InvitePeopleMailer < BaseMailer
  def to_start_group(invitation, sender_email)
    @invitation = invitation
    mail to: invitation.recipient_email,
         from: 'Loomio <contact@loomio.org>',
         reply_to: sender_email,
         subject: "Your Loomio group: #{@invitation.group_name} has been created"
  end

  def to_join_group(invitation, sender_email, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email,
         from: 'Loomio <contact@loomio.org>',
         reply_to: sender_email,
         subject: "#{@invitation.inviter.name} has invited you to join #{@invitation.group_name} on Loomio"
  end

  def after_membership_request_approval(invitation, sender_email, message_body)
    @invitation = invitation
    @group = @invitation.group
    @message_body = message_body
    mail to: invitation.recipient_email,
         from: 'Loomio <contact@loomio.org>',
         reply_to: sender_email,
         subject: "#{email_subject_prefix(@group.full_name)} " + t("email.group_membership_approved.subject")
  end
end
