class NotificationsIndex < ActiveRecord::Migration
  def change
    remove_index :notifications, :created_at
    add_index :notifications, :created_at, order: {created_at: 'DESC'}
  end
end
