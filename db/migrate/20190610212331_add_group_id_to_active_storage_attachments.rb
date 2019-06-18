class AddGroupIdToActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :active_storage_attachments, :group_id, :integer
    add_index :active_storage_attachments, :group_id
  end
end
