module Events::Notify::Users
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.active.without(user).uniq.each do |recipient|
      mailer.delay.send(kind, recipient, self)
    end
  end
  handle_asynchronously :email_users!

  # which mailer should be used to send emails about this event?
  def mailer
    "#{eventable.class}Mailer".constantize
  end

  private

  # which users should receive an email about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def email_recipients
    User.none
  end
end
