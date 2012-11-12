namespace :emails do
  task :send_daily_summary => :environment do
    since_time = 24.hours.ago
    User.daily_activity_email_recipients.each do |user|
      recent_activity = CollectsRecentActivityByGroup.for(user, since: since_time)
      UserMailer.daily_activity(user, recent_activity, since_time).deliver!
    end
  end

  task :send_proposal_closing_soon => :environment do
    one_hour_window = (1.day.from_now) ... (1.day.from_now + 1.hour)
    Motion.where(:close_date => one_hour_window).each do |motion|
      Event.motion_closing_soon!(motion)
    end
  end
end
