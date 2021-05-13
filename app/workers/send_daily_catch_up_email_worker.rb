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
          days = [7, time_in_zone.wday, (time_in_zone.wday % 2 == 1) ? 8 : nil].compact
          User.active.verified.where(time_zone: zone)
          .where(email_catch_up_day: days).find_each do |user|
            period = case user.email_catch_up_day
              when 8 then 'other'
              when 7 then 'daily'
              else
                'weekly'
              end
            UserMailer.delay(queue: :low).catch_up(user.id, nil, period)
          end
        end
      end
    end
  end
end
