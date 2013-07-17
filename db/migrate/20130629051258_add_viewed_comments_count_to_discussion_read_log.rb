class AddViewedCommentsCountToDiscussionReadLog < ActiveRecord::Migration
  def change
    add_column :discussion_read_logs, :viewed_comments_count, :integer
  end
end
