class RenameDiscussionReadLogsToDiscussionViewers < ActiveRecord::Migration
  def up
    rename_table :discussion_read_logs, :discussion_readers
  end

  def down
    rename_table :discussion_readers, :discussion_read_logs
  end
end
