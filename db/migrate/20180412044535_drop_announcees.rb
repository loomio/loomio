class DropAnnouncees < ActiveRecord::Migration[5.1]
  def change
    drop_table :announcements
    drop_table :announcees
  end
end
