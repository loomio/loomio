class AddViewedAtToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :viewed_at, :datetime
  end
end
