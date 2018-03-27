class AddAnnouncementCount < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :announcements_count, :integer, default: 0, null: false
    add_column :discussions, :announcements_count, :integer, default: 0, null: false
    add_column :outcomes, :announcements_count, :integer, default: 0, null: false
  end
end
