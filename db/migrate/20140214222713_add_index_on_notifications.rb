class AddIndexOnNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, [:event_id, :user_id]
  end
end
