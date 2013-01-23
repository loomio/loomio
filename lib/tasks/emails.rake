namespace :emails do
  task :send_daily_summary => :environment do
    # JL: Really this time should be rounded to the nearest few minutes so that if
    # the cronjob gets called at a slightly different time (within say 30 seconds)
    # that we don't lose any data (at the moment we do)
    # To test carefully for this, we should really write some unit tests for this rake task
    SendActivitySummary.to_subscribers!
  end

  task :send_proposal_closing_soon => :environment do
    # JL: Really this time should be rounded to the nearest few minutes so that if
    # the cronjob gets called at a slightly different time (within say 30 seconds)
    # that we don't lose any data (at the moment we do)
    # To test carefully for this, we should really write some unit tests for this rake task
    one_hour_window = (1.day.from_now) ... (1.day.from_now + 1.hour)
    Motion.where(:close_date => one_hour_window).each do |motion|
      Events::MotionClosingSoon.publish!(motion)
    end
  end
end
