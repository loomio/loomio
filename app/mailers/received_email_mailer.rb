class ReceivedEmailMailer < BaseMailer
  layout 'invite_people_mailer'
  def user_not_found(sender_address)
    send_single_mail to: sender_address,
                     subject_key: "received_email_mailer.user_not_found.subject",
                     subject_params: { sender_address: sender_address },
                     locale: I18n.default_locale
  end
  def group_not_found(sender_address, handle)
    @handle = handle
    send_single_mail to: sender_address,
                     subject_key: "received_email_mailer.group_not_found.subject",
                     subject_params: { handle: handle },
                     locale: I18n.default_locale
  end
end
