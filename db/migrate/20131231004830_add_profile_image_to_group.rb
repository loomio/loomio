class AddProfileImageToGroup < ActiveRecord::Migration
  def self.up
    add_attachment :groups, :profile_image
  end
  def self.down
    remove_attachment :groups, :profile_image
  end
end
