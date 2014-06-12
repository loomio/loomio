class AddCoverPhotoToGroup < ActiveRecord::Migration
  def self.up
    add_attachment :groups, :cover_photo
  end
  def self.down
    remove_attachment :groups, :cover_photo
  end
end
