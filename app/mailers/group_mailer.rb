class GroupMailer < BaseMailer
  def destroy_warning(group_id, recipient_id, deletor_id)
    @group = Group.find(group_id)
    @recipient = User.find(recipient_id)
    @deletor = User.find(deletor_id)

    send_single_mail  to: @recipient.name_and_email,
                      reply_to: ENV['SUPPORT_EMAIL'],
                      subject_key: "group_mailer.destroy_warning.subject",
                      locale: @recipient.locale
  end
end
