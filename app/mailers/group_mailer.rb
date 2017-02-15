class GroupMailer < BaseMailer
  layout 'invite_people_mailer'

  def membership_requested(recipient, event)
    @membership_request = event.eventable
    @group = @membership_request.group
    @introduction = @membership_request.introduction
    send_single_mail  to: recipient.name_and_email,
                      reply_to: "#{@membership_request.name} <#{@membership_request.email}>",
                      subject_key: "email.membership_request.subject",
                      subject_params: {who: @membership_request.name, which_group: @group.full_name},
                      locale: locale_for(recipient)
  end
end
