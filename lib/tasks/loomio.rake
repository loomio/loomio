namespace :loomio do
  task :version do
    puts Loomio::Version.current
  end

  task generate_static_error_pages: :environment do
    [400, 404, 410, 417, 422, 429, 500].each do |code|
      File.open("public/#{code}.html", "w+") do |f|
        f << "<!-- This file is automatically generated by rake loomio:generate_static_error_pages -->\n"
        f << "<!-- Don't make changes here; they will be overwritten. -->\n"
        f << ApplicationController.new.render_to_string(
          template: "errors/#{code}",
          layout: "error"
        )
      end
    end
  end

  task generate_static_translations: :environment do
    Loomio::I18n::SELECTABLE_LOCALES.each do |locale|
      puts "Writing public/translations/#{locale}.json..."
      File.write("public/translations/#{locale}.json", ClientTranslationService.new(locale).to_json)
    end
  end

  task hourly_tasks: :environment do
    PollService.delay.expire_lapsed_polls
    PollService.delay.publish_closing_soon
    SendMissedYesterdayEmailJob.perform_later
    ResendIgnoredInvitationsJob.perform_later
    LocateUsersAndGroupsJob.perform_later
    if (Time.now.hour == 0)
      # daily tasks
      UsageReportService.send
    end
  end

  task resend_ignored_invitations: :environment do
    InvitationService.resend_ignored(send_count: 1, since: 1.day.ago)
    InvitationService.resend_ignored(send_count: 2, since: 3.days.ago)
  end

  task refresh_likes: :environment do
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Comment.count )

    Comment.find_each do |c|
      progress_bar.increment
      c.refresh_liker_ids_and_names!
    end
  end

  task refresh_comment_versions: :environment do
    progress_bar = ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Comment.count )

    Comment.find_each(batch_size: 200) do |c|
      progress_bar.increment
      c.update_versions_count
    end
  end

  task refresh_discussion_versions: :environment do
    progress_bar = ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Discussion.count )

    Discussion.find_each(batch_size: 200) do |d|
      progress_bar.increment
      d.update_versions_count
    end
  end

  task refresh_public_discussions_count: :environment do
    progress_bar = ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Group.count )

    Group.find_each(batch_size: 200) do |g|
      progress_bar.increment
      g.update_public_discussions_count
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

  task tag_and_measure_cohorts: :environment do
    CohortService.tag_groups
  end

  task notify_clients_of_update: :environment do
    MessageChannelService.publish({ version: Loomio::Version.current }, to: GlobalMessageChannel.instance)
  end
end
