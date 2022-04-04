module Events::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send event emails
  def email_users!
    email_recipients.active.uniq.pluck(:id).each do |recipient_id|
      EventMailer.event(recipient_id, self.id).deliver_later
    end
  end
end
