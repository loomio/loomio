class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user
      t.string :kind
      t.references :discussion
      t.references :comment
      t.references :motion

      t.timestamps
    end
    add_index :notifications, :user_id
    add_index :notifications, :discussion_id
    add_index :notifications, :comment_id
    add_index :notifications, :motion_id
  end
end
