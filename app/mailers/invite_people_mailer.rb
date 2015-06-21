class InvitePeopleMailer < BaseMailer
  def to_start_group(invitation, sender_email)
    @invitation = invitation
    mail to: invitation.recipient_email,
         reply_to: sender_email,
         subject: t("email.to_start_group.subject", group_name: @invitation.invitable_name)
  end

  def to_join_group(invitation, sender, message_body, subject: nil)
    @invitation = invitation
    @message_body = message_body
    mail to: invitation.recipient_email,
         from: from_user_via_loomio(sender),
         reply_to: sender.name_and_email,
         subject: subject || t("email.to_join_group.subject",
           member: @invitation.inviter.name,
           group_name: @invitation.invitable_name)
  end

  #def to_join_discussion(invitation, sender, message)
    #@invitation = invitation
    #@discussion = invitation.invitable
    #@inviter = invitation.inviter
    #@message = message
    #mail to: invitation.recipient_email,
         #from: from_user_via_loomio(sender),
         #reply_to: sender.name_and_email,
         #subject: t("email.to_join_discussion.subject", who: @invitation.inviter.name)
  #end

  def after_membership_request_approval(invitation, sender_email, message_body)
    @invitation = invitation
    @group = @invitation.group
    @message_body = message_body
    mail to: invitation.recipient_email,
         reply_to: sender_email,
         subject: "#{email_subject_prefix(@group.full_name)} " + t("email.group_membership_approved.subject")
  end
end
