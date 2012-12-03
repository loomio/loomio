class SendActivitySummary
  def self.to_subscribers!
    since_time = 24.hours.ago
    User.daily_activity_email_recipients.each do |user|
      results = CollectsRecentActivityByGroup.new(user, since: since_time).results
      if results.present?
        UserMailer.daily_activity(user, results, since_time).deliver!
      end
    end
  end
end
