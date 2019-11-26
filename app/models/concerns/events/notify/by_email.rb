module Events::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.active.where.not(id: user).uniq.each do |recipient|
      eventable.send(:mailer).delay(queue: :notification_emails).send(email_method, recipient, self)
    end
  end
  handle_asynchronously :email_users!, queue: :notification_emails

  # override to specify a custom subject for emails sent by this event
  def email_subject_key
    nil
  end

  private
  def email_method
    kind
  end

  # which users should receive an email about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def email_recipients
    User.none
  end
end
