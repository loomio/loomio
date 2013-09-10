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
    #funky!
    if DiscussionReader.present?
      DiscussionReadLog = DiscussionReader
      last_viewed_at_column_name = 'last_read_at'
    else
      last_viewed_at_column_name = 'discussion_last_viewed_at'
    end
      
    DiscussionReadLog.reset_column_information
    DiscussionReadLog.find_each do |drl|
      if drl.discussion.present?
        count = drl.discussion.comments.where('updated_at <= ?', drl.send(last_viewed_at_column_name)).count
        drl.update_attribute(:read_comments_count, count)
      end

      if drl.id % 100 == 0
        puts 'Updating read_comments_counts for DiscussionReaders: '+drl.id.to_s
      end
    end
  end

  task :reset_comment_likers => :environment do
    Comment.find_each do |c|
      puts c.id if c.id % 100 == 0
      c.comment_votes.each do |cv|
        c.liker_ids_and_names[cv.user_id] = cv.user.name
      end
      c.save(validate: false)
    end
  end
end
