class AddFollowingToDiscussionReadLogs < ActiveRecord::Migration
  def change
    add_column :discussion_read_logs, :following, :boolean, default: true, null: false
  end
end
