class RemoveGroupIdFromActiveStorageAttachments < ActiveRecord::Migration[8.1]
  def change
    remove_index :active_storage_attachments, :group_id, if_exists: true
    remove_column :active_storage_attachments, :group_id, :integer
  end
end
