class AnnouncementShift < ActiveRecord::Migration[5.1]
  def change
    remove_column :announcements, :kind, :string
    remove_column :announcements, :announceable_id, :integer
    remove_column :announcements, :announceable_type, :string
    add_column :announcements, :event_id, :integer, index: true
  end
end
