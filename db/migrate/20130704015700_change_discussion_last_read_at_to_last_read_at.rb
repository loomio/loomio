class ChangeDiscussionLastReadAtToLastReadAt < ActiveRecord::Migration
  def up
    rename_column :discussion_readers, :discussion_last_viewed_at, :last_read_at
  end

  def down
    rename_column :discussion_readers, :last_read_at, :discussion_last_viewed_at
  end
end
