class RemoveUnnecessaryColumnsFromEvents < ActiveRecord::Migration
  def change
    remove_column :notifications, :discussion_id
    remove_column :notifications, :comment_id
    remove_column :notifications, :motion_id
    remove_column :notifications, :kind
  end
end
