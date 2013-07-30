namespace :upgrade_tasks do
  task :update_comments_counts => :environment do
    Discussion.reset_column_information
    Discussion.find_each do |d|
      if d.comments_count != d.comments.count
        puts "updaing discussion id: #{d.id} current: #{d.comments_count} actual: #{d.comments.count}"
        d.update_attribute(:comments_count, d.comments.count)
      end

    end
  end
  task :update_read_comments_counts => :environment do
    DiscussionReadLog.reset_column_information
    DiscussionReadLog.find_each do |drl|
      if drl.discussion.present?
        count = drl.discussion.comments.where('updated_at <= ?', drl.discussion_last_viewed_at).count
        drl.update_attribute(:read_comments_count, count)
      end

      if drl.id % 100 == 0
        puts drl.id
      end
    end
  end
end
