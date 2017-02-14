module Events::EmailUser
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!(recipients = email_recipients)
    recipients.without(user).each { |recipient| mailer.send(kind, recipient, self).deliver_now }
  end
  handle_asynchronously :email_users!

  private

  # which users should receive an email about this event?
  def email_recipients
    User.none
  end

  # which mailer should be used to send emails about this event?
  def mailer
    ThreadMailer
  end
end
