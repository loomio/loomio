class GroupMailer < BaseMailer
  layout 'invite_people_mailer'

  def group_announced(recipient, event)
    return unless @membership = event.eventable.memberships.find_by(user: recipient)
    @inviter = @membership.inviter || recipient
    send_single_mail to:     recipient.email,
                     locale: recipient.locale,
                     from:   from_user_via_loomio(@inviter),
                     reply_to: @inviter.name_and_email,
                     subject_key: event.email_subject_key || "email.to_join_group.subject",
                     subject_params: {member: @inviter.name,
                                      group_name: @membership.group.full_name,
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
                      locale: recipient.locale
  end
end
