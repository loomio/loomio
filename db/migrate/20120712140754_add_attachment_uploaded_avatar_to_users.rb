class AddAttachmentUploadedAvatarToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.has_attached_file :uploaded_avatar
    end
  end

  def self.down
    drop_attached_file :users, :uploaded_avatar
  end
end
