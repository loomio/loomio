class InvitePeopleMailer < BaseMailer
  def to_start_group(invitation:,
                     sender_email: ,
                     locale: )

    @invitation = invitation
    send_single_mail to:       @invitation.recipient_email,
                     locale:   locale,
                     reply_to: sender_email,
                     subject_key: "email.to_start_group.subject",
                     subject_params: {group_name: @invitation.invitable_name}
  end

  def to_join_group(invitation: , locale: )
    @invitation = invitation
    @message_body = invitation.message
    send_single_mail to:   @invitation.recipient_email,
                     locale: locale,
                     from: from_user_via_loomio(invitation.inviter),
                     reply_to: invitation.inviter.name_and_email,
                     subject_key: "email.to_join_group.subject",
                     subject_params: {member: @invitation.inviter.name, group_name: @invitation.invitable_name}
  end

  def after_membership_request_approval(invitation, sender_email, message_body)
    @invitation = invitation
    @group = @invitation.group
    @message_body = message_body
    send_single_mail to:       @invitation.recipient_email,
                     locale:   I18n.locale,
                     reply_to: sender_email,
                     subject_key: "email.group_membership_approved.subject",
                     subject_params: {prefix: email_subject_prefix(@group.full_name)}
  end
end
