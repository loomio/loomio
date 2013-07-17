class RenameViewedCommentsCountToReadCommentsCount < ActiveRecord::Migration
  def up
    rename_column :discussion_readers, :viewed_comments_count, :read_comments_count
  end

  def down
    rename_column :discussion_readers, :read_comments_count, :viewed_comments_count
  end
end
