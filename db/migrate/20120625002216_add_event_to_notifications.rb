class AddEventToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :event_id, :integer
    add_index :notifications, :event_id
  end
end
