class AddAnnouncementToEvents < ActiveRecord::Migration
  def change
    add_column :events, :announcement, :boolean, null: false, default: false
  end
end
