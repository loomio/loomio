namespace :loomio do
  task tail_call: :environment do
    RubyVM::InstructionSequence.compile_option = {
      :tailcall_optimization => true,
      :trace_instruction => false
    }
  end

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

  task refresh_likes: :environment do
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Comment.count )

    Comment.find_each do |c|
      progress_bar.increment
      c.refresh_liker_ids_and_names!
    end
  end

  task fix_unread: :environment do
    puts "Recounting discussion reader counts"
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: DiscussionReader.count )

    DiscussionReader.find_each do |dr|
      progress_bar.increment
      next unless dr.valid?
      next unless dr.discussion.present?
      next unless dr.user.present?
      dr.reset_counts!
    end
  end

  task tag_cohorts: :environment do
    CohortService.tag_groups
    puts "Tagged all groups into cohorts"
  end

  task measure_groups: :environment do
    MeasurementService.measure_groups(Time.zone.yesterday)
  end
end
