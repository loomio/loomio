class ModifyNotificationsIndexes < ActiveRecord::Migration
  def up
    remove_index :notifications, name: "index_notifications_on_event_id_and_user_id"
    add_index :notifications, :created_at
  end
end
