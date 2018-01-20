module Events::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.active.where.not(id: user).uniq.each do |recipient|
      eventable.send(:mailer).delay.send(kind, recipient, self)
    end
  end
  handle_asynchronously :email_users!

  private

  # which users should receive an email about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def email_recipients
    User.none
  end
end
