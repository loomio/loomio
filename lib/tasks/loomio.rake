namespace :loomio do
  task :send_proposal_closing_soon => :environment do
    Delayed::Job.enqueue ProposalsClosingSoonJob.new
  end

  task :close_lapsed_motions => :environment do
    MotionService.close_all_lapsed_motions
  end

  task send_missed_yesterday_email: :environment do
    SendMissedYesterdayEmail.to_subscribers!
  end

  task :generate_error => :environment do
    raise "Testing error reporting for rake tasks, chill, no action requied if you see this"
  end

  task fix_unread: :environment do
    puts "Correcting slightly wrong last_read_at values"
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: DiscussionReader.count )
    DiscussionReader.find_each do |dr|
      progress_bar.increment
      next unless dr.valid?
      next unless dr.discussion.present?
      next unless dr.user.present?
      dr.viewed!(dr.discussion.last_activity_at) unless dr.unread_content_exists?
    end
  end
end
