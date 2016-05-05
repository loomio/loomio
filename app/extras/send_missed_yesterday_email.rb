class SendMissedYesterdayEmail
  def self.to_subscribers!
    zones = User.pluck('DISTINCT time_zone').select do |zone|
      Time.find_zone(zone) &&
      DateTime.now.in_time_zone(zone).hour == 6
    end

    User.email_missed_yesterday.where(time_zone: zones).find_each do |user|
      puts "Emailing yesterdays activity to #{user.name_and_email}"
      UserMailer.delay.missed_yesterday(user)
    end
  end
end
