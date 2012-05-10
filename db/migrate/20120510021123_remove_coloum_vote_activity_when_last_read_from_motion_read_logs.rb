class RemoveColoumVoteActivityWhenLastReadFromMotionReadLogs < ActiveRecord::Migration
  def up
    remove_column :motion_read_logs, :vote_activity_when_last_read
  end

  def down
    add_column :motion_read_logs, :vote_activity_when_last_read, :integer
  end
end
