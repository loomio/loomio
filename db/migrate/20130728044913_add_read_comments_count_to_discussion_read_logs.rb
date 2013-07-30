class AddReadCommentsCountToDiscussionReadLogs < ActiveRecord::Migration
  def up
    add_column :discussion_read_logs, :read_comments_count, :integer
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
