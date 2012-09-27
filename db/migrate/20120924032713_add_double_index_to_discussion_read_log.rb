class AddDoubleIndexToDiscussionReadLog < ActiveRecord::Migration
  def change
    add_index :discussion_read_logs, [:user_id, :discussion_id]
  end
end
