module Events::EmailUser

  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.without(user).each { |recipient| email_user!(recipient) }
  end
  handle_asynchronously :email_users!

  # which mailer should be used to send emails about this event?
  def mailer
    ThreadMailer
  end

  private

  def email_user!(recipient)
    mailer.delay.send(kind, recipient, self)
  end

  # which users should receive an email about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def email_recipients
    User.none
  end

end
