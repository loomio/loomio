module Events::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.active.where.not(id: user.id || 0).uniq.pluck(:id).each do |recipient_id|
      eventable.send(:mailer).delay(queue: :notification_emails).send(email_method, recipient_id, self.id)
    end
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
