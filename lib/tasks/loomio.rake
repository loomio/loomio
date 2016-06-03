namespace :loomio do
  task :version do
    puts Loomio::Version.current
  end

  task hourly_tasks: :environment do
    MotionService.close_all_lapsed_motions
    SendMissedYesterdayEmailJob.perform_later
    ResendIgnoredInvitationsJob.perform_later
    ProposalsClosingSoonJob.perform_later
    LocateUsersAndGroupsJob.perform_later
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
    MeasurementService.measure_groups(Date.yesterday)
  end

  task measure_groups_lots: :environment do
    CohortService.tag_groups
    date = 10.weeks.ago.to_date
    while(date < Date.today) do
      puts 'hi'
      MeasurementService.measure_groups(date)
      puts "measured #{date}"
      date = date + 1.day
    end
  end

  task update_blog_stories: :environment do
    rss = SimpleRSS.parse open('http://blog.loomio.org/category/stories/feed/')
    BlogStory.destroy_all
    rss.items.each do |item|
      BlogStory.create(title: item[:title],
                       url: item[:link],
                       image_url: item[:media_content_url].try(:gsub, "http://", "https://"),
                       published_at: item[:pubDate])
    end
  end

  task notify_clients_of_update: :environment do
    MessageChannelService.publish({ version: Loomio::Version.current }, to: GlobalMessageChannel.instance)
  end
end
