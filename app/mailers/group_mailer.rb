class GroupMailer < BaseMailer
  layout 'invite_people_mailer'

  # recipient is an invitation
  def invitation_created(recipient, event)
    @recipient = recipient
    send_single_mail to:     recipient.email,
                     locale: recipient.locale,
                     from:   from_user_via_loomio(recipient.inviter),
                     reply_to: recipient.inviter.name_and_email,
                     subject_key: "email.to_join_group.subject",
                     subject_params: {member: recipient.inviter.name,
                                      group_name: recipient.group.full_name,
                                      site_name: AppConfig.theme[:site_name]}
  end

  def invitation_resend(recipient, event)
    @recipient = recipient
    send_single_mail to:     recipient.email,
                     locale: recipient.locale,
                     from:   from_user_via_loomio(recipient.inviter),
                     reply_to: recipient.inviter.name_and_email,
                     subject_key: "email.resend_to_join_group.subject",
                     template_name: :invitation_created,
                     subject_params: {member: recipient.inviter.name,
                                      group_name: recipient.group.full_name,
                                      site_name: AppConfig.theme[:site_name]}
  end

  def membership_requested(recipient, event)
    @membership_request = event.eventable
    @group = @membership_request.group
    @introduction = @membership_request.introduction
    send_single_mail  to: recipient.name_and_email,
                      reply_to: "#{@membership_request.name} <#{@membership_request.email}>",
                      subject_key: "email.membership_request.subject",
                      subject_params: {who: @membership_request.name, which_group: @group.full_name, site_name: AppConfig.theme[:site_name]},
                      locale: locale_for(recipient)
  end
end
