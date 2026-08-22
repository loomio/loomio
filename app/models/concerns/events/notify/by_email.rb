module Events::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send event emails to the email_recipients
  def email_users!
    email_recipients.active.no_spam_complaints.uniq.pluck(:id).each do |recipient_id|
      if respond_to?(:did_create_in_app_notification_for?, true)
        next unless did_create_in_app_notification_for?(recipient_id)
      end

      EventMailer.event(recipient_id, self.id).deliver_later
    end
  end
end
