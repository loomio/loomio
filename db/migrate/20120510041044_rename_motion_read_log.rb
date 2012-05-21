class RenameMotionReadLog < ActiveRecord::Migration
  def up
    rename_table :motion_read_logs, :discussion_read_logs
  end

  def down
    rename_table :discussion_read_logs, :motion_read_logs
  end
end
