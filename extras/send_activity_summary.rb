class SendActivitySummary
  def self.subscribers_this_hour!
    User.activity_summary_email_recipients_this_hour.each do |user|
      UserMailer.activity_summary(user).deliver
      user.email_preferences.set_last_sent_at
    end
  end
end
