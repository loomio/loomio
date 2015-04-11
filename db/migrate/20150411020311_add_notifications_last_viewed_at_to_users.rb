class AddNotificationsLastViewedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notifications_last_viewed_at, :datetime
  end
end
