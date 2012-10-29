class AddMotionLastViewedAtToMotionReadLogs < ActiveRecord::Migration
  class MotionReadLog < ActiveRecord::Base
  end
  def up
    add_column :motion_read_logs, :motion_last_viewed_at, :datetime
    MotionReadLog.reset_column_information
    MotionReadLog.where(:motion_last_viewed_at => nil).update_all :motion_last_viewed_at => Time.now
    change_column :motion_read_logs, :motion_last_viewed_at, :datetime, :null => true
    remove_column :motion_read_logs, :motion_activity_when_last_read
  end

  def down
    remove_column :motion_read_logs, :motion_last_viewed_at
    add_column :motion_read_logs, :motion_activity_when_last_read, :integer, :default => 0
  end
end
