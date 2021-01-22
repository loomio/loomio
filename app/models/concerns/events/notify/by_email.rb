module Events::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.active.uniq.pluck(:id).each do |recipient_id|
      eventable.send(:mailer).delay(queue: :critical).send(email_method, recipient_id, self.id)
    end
  end

  private
  def email_method
    kind
  end
end
