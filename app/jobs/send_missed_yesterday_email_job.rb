class SendMissedYesterdayEmailJob < ActiveJob::Base
  def perform
    zones = User.pluck('DISTINCT time_zone').select do |zone|
      Time.find_zone(zone) && DateTime.now.in_time_zone(zone).hour == 6
    end

    User.email_missed_yesterday.where(time_zone: zones).find_each do |user|
      UserMailer.delay(priority: 30).missed_yesterday(user)
    end
  end
end
