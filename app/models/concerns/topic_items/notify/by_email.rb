module TopicItems::Notify::ByEmail
  def trigger!
    super
    email_users!
  end

  # send topic_item emails to the email_recipients
  def email_users!
    email_recipients.active.no_spam_complaints.uniq.pluck(:id).each do |recipient_id|
      NotificationMailer.topic_item(recipient_id, id).deliver_later
    end
  end
end
