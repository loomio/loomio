class RemoveUrlFromNotifications < ActiveRecord::Migration[8.0]
  def change
    remove_column :notifications, :url, :string
  end
end
