namespace :emails do
  task :send_activity_summary => :environment do
    SendActivitySummary.subscribers_this_hour!
  end

  task :send_proposal_closing_soon => :environment do
    Delayed::Job.enqueue ProposalsClosingSoonJob.new
  end
end
