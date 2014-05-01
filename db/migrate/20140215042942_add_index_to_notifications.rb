class AddIndexToNotifications < ActiveRecord::Migration
  def change
    add_index :notifications, :viewed_at
  end
end
