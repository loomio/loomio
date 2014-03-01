class InvitePeopleMailer < BaseMailer
  def to_start_group(invitation, sender_email)
    @invitation = invitation
    mail to: invitation.recipient_email,
         from: 'Loomio <contact@loomio.org>',
         reply_to: sender_email,
         subject: t("email.to_start_group.subject", group_name: @invitation.invitable_name)
  end

  def to_join_group(invitation, sender, message_body)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email,
         from: "#{sender.name} <notifications@loomio.org>",
         reply_to: sender.email,
         subject: t("email.to_join_group.subject", member: @invitation.inviter.name, group_name: @invitation.invitable_name)
  end

  def to_join_discussion(invitation, sender, message)
    @invitation = invitation
    @discussion = invitation.invitable
    @inviter = invitation.inviter
    @message = message
    mail to: invitation.recipient_email,
         from: "#{sender.name} <notifications@loomio.org>",
         reply_to: sender.email,
         subject: t("email.to_join_discussion.subject", who: @invitation.inviter.name)
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

  def welcome(group)
    @group = group
    @recipient = group.admins.first
    mail  to: @recipient.email,
          from: 'Richard Bartlett <rich@loomio.org>',
          subject: 'Welcome to Loomio!'
  end
end
