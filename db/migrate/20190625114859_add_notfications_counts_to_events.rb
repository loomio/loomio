class AddNotficationsCountsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :notifications_count, :integer, null: true
    add_column :events, :viewed_notifications_count, :integer, null: true
  end
end
