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

  # rake loomio:fetch_remote_database[`heroku pgbackups:url -a loomio-production`]
  task :fetch_remote_database, :url, :dbname do |t, args|
    args.with_defaults dbname: :loomio_production
    args.with_defaults filename: "~/#{args[:dbname]}-#{Time.now.strftime('%Y-%m-%d')}.dump",
                       latest_filename: "~/#{args[:dbname]}-latest.dump"

    puts "Fetch remote database... (this may take a bit)"
    sh "wget #{args[:url]} -O #{args[:filename]}"
    sh "rm ~/#{args[:dbname]}"
    sh "ln -s #{args[:latest_filename]} #{args[:filename]}"
    puts "Resetting local #{args[:dbname]} database..."
    sh "dropdb #{args[:dbname]}"
    sh "createdb #{args[:dbname]}"
    puts "Saving database to local #{args[:dbname]} database..."
    sh "pg_restore --verbose --clean --no-acl --no-owner -d #{args[:dbname]} #{args[:latest_filename]}"
    puts "All set! Run `rake loomio:restore_remote_database` to load this restore your local database with this data."
  end

  # rake loomio:restore_remote_database
  task :restore_remote_database, :target, :source do |t, args|
    args.with_defaults target: :loomio_development, source: :loomio_production

    puts "Restoring data from #{args[:source]} to #{args[:target]}..."
    sh "dropdb #{args[:target]}"
    sh "createdb #{args[:target]} -T #{args[:source]}"
    puts "Success!"
  end
end
