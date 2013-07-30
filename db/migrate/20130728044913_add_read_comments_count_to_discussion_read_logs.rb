class AddReadCommentsCountToDiscussionReadLogs < ActiveRecord::Migration
  def up
    add_column :discussion_read_logs, :read_comments_count, :integer
  end

  def down
  end
end
