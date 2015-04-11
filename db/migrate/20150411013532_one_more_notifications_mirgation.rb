class OneMoreNotificationsMirgation < ActiveRecord::Migration
  def change
    remove_column :notifications, :viewed_at
  end
end
