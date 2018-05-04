class AddAuthorToAnnouncement < ActiveRecord::Migration[4.2]
  def change
    add_column :announcements, :author_id, :integer, default: false, index: true
  end
end
