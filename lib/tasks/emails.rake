namespace :emails do
  task :send_daily_summary => :environment do
    # JL: Really this time should be rounded to the nearest few minutes so that if
    # the cronjob gets called at a slightly different time (within say 30 seconds)
    # that we don't lose any data (at the moment we do)
    # To test carefully for this, we should really write some unit tests for this rake task
    since_time = 24.hours.ago
    User.daily_activity_email_recipients.each do |user|
      recent_activity = CollectsRecentActivityByGroup.for(user, since: since_time)
      if recent_activity[:any_activity?]
        puts "sending daily email for: #{user.email}"
        UserMailer.daily_activity(user, recent_activity, since_time).deliver!
      end
    end
  end

  task :send_proposal_closing_soon => :environment do
    # JL: Really this time should be rounded to the nearest few minutes so that if
    # the cronjob gets called at a slightly different time (within say 30 seconds)
    # that we don't lose any data (at the moment we do)
    # To test carefully for this, we should really write some unit tests for this rake task
    one_hour_window = (1.day.from_now) ... (1.day.from_now + 1.hour)
    Motion.where(:close_date => one_hour_window).each do |motion|
      Event.motion_closing_soon!(motion)
    end
  end
end
