# NB: don't include this module on it's own! Use Notify::Users or Notify::Visitors instead
module Events::Notify::Email
  # which mailer should be used to send emails about this event?
  def mailer
    ThreadMailer
  end

  private

  def email_user!(recipient)
    mailer.delay.send(kind, recipient, self)
  end
end
