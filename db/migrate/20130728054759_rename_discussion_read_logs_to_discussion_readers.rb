class RenameDiscussionReadLogsToDiscussionReaders < ActiveRecord::Migration
  def up
    rename_table :discussion_read_logs, :discussion_readers
    rename_column :discussion_readers, :discussion_last_viewed_at, :last_read_at
  end

  def down
    rename_column :discussion_readers, :last_read_at, :discussion_last_viewed_at
    rename_table :discussion_readers, :discussion_read_logs
  end
end
