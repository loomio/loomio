class GroupMailer < BaseMailer
  layout 'invite_people_mailer', only: [:membership_request]

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

  def group_email(group, sender, subject, message, recipient)
    @group = group
    @sender = sender
    @message = message
    @recipient = recipient
    send_single_mail  to: @recipient.email,
                      reply_to: sender.name_and_email,
                      subject_key: "email.custom",
                      subject_params: {text: "#{email_subject_prefix(@group.full_name)} #{subject}"},
                      locale: locale_for(recipient, sender)
  end

  def self.deliver_group_email(group, sender, subject, message)
    send_bulk_mail(to: (group.users - Array(sender))) do |user|
      GroupMailer.group_email(group, sender, subject, message, user).deliver_later
    end
  end
end
