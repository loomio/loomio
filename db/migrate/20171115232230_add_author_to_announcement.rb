class AddAuthorToAnnouncement < ActiveRecord::Migration
  def change
    add_column :announcements, :author_id, :integer, default: false, index: true
  end
end
