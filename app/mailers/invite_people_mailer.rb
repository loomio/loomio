class InvitePeopleMailer < BaseMailer
  layout 'invite_people_mailer'
  def after_membership_request_approval(invitation, sender_email, message_body)
    @invitation = invitation
    @group = @invitation.group
    @message_body = message_body
    send_single_mail to:       @invitation.recipient_email,
                     locale:   first_supported_locale(@invitation.inviter.locale),
                     reply_to: sender_email,
                     subject_key: "email.group_membership_approved.subject",
                     subject_params: {group_name: @group.full_name}
  end
end
