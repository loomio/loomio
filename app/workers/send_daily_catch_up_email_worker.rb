class SendDailyCatchUpEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: true

  def perform
    # email users who have day = 7 and hour = 6
    # and email users with day = today and hour = 6
    User.pluck('DISTINCT time_zone').each do |zone|
      if Time.find_zone(zone)
        time_in_zone = DateTime.now.in_time_zone(zone)
        if time_in_zone.hour == 6
          User.where(time_zone: zone)
          .where('email_catch_up_day = 7 or email_catch_up_day = ?', time_in_zone.day).find_each do |user|
            period = user.email_catch_up_day == 7 ? 'daily' : 'weekly'
            UserMailer.delay(queue: :low).catch_up(user.id, nil, period)
          end
        end
      end
    end
  end
end
