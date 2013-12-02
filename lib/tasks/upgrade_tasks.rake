require_relative '../../extras/migrations/migrate_motions_closed_by_user'
namespace :upgrade_tasks do
  task :'2013-11-29-motion-closed-by-user' => :environment do
    MigrateMotionsClosedByUser.now
  end

  task :'2013-10-add-discussion-item-number' => :environment do
    ActiveRecord::Base.record_timestamps = false
    begin
      Discussion.find_each do |d|
        d.items.order('created_at asc').each do |event|
          event.save
        end
        puts d.id if (d.id % 100) == 0
      end
    ensure
      ActiveRecord::Base.record_timestamps = true  # don't forget to enable it again!
    end
  end

  task :'2013-10-part2-update_item_counts_post_counter_caches' => :environment do
    puts 'Updating discussions.items_count'
    Discussion.find_each do |d|
      puts d.id if d.id % 100 == 0
      Discussion.reset_counters(d.id, :items)
    end

    puts 'Updating discussion_readers.read_items_count'
    DiscussionReader.find_each do |dr|
      next unless dr.discussion.present?
      puts dr.id if dr.id % 100 == 0
      dr.update_attribute(:read_items_count,
                          dr.discussion.items.where('created_at <= ?', dr.last_read_at).count)
    end
  end

  task :'2013-10-part1-update_item_counts_pre_counter_caches' => :environment do
    puts 'Updating discussions.items_count'
    Discussion.find_each do |d|
      puts d.id if d.id % 100 == 0
      d.update_attribute(:items_count, Event.where(discussion_id: d.id).count)
    end

    puts 'Updating discussion_readers.read_items_count'
    DiscussionReader.find_each do |dr|
      next unless dr.discussion.present?
      puts dr.id if dr.id % 100 == 0
      dr.update_attribute(:read_items_count,
                          Event.where(discussion_id: dr.discussion.id).
                                where('created_at <= ?', dr.last_read_at).count)
    end

  end

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

  task :"2013-09_destroy_dangling_discussion_events" => :environment do
    puts "Destroying discussion events:"
    Event.where("discussion_id IS NOT NULL").find_each do |event|
      if event.discussion.nil?
        puts event.id
        event.destroy
      end
    end
  end

  task :"2013-09_destroy_dangling_motions" => :environment do
    puts "Destroying motions:"
    Motion.find_each do |motion|
      if motion.discussion.nil?
        puts motion.id
        motion.destroy
      end
    end
  end

  task :"2013-09_destroy_dangling_comments" => :environment do
    puts "Destroying comments:"
    Comment.find_each do |comment|
      if comment.discussion.nil?
        puts comment.id
        comment.destroy
      end
    end
  end

  task :"2013-09_destroy_dangling_comment_votes" => :environment do
    puts "Destroying comment votes:"
    CommentVote.find_each do |comment_vote|
      if comment_vote.comment.nil?
        puts comment_vote.id
        comment_vote.destroy
      end
    end
  end
end
