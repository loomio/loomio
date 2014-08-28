namespace :loomio do
  task send_proposal_closing_soon: :environment do
    Delayed::Job.enqueue ProposalsClosingSoonJob.new
  end

  task close_lapsed_motions: :environment do
    MotionService.close_all_lapsed_motions
  end

  task send_missed_yesterday_email: :environment do
    SendMissedYesterdayEmail.to_subscribers!
  end

  task generate_error: :environment do
    raise "Testing error reporting for rake tasks. Chill, no action requied if you see this"
  end
end
