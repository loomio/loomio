class AddDiscussionLastViewedAtToDiscussionReadLogs < ActiveRecord::Migration
  def up
    add_column :discussion_read_logs, :discussion_last_viewed_at, :datetime, :default => Time.now
    remove_column :discussion_read_logs, :discussion_activity_when_last_read
  end

  def down
    remove_column :discussion_read_logs, :discussion_last_viewed_at
    add_column :discussion_read_logs, :discussion_activity_when_last_read, :integer, :default => 0
  end
end
