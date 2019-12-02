class EnsureGroupIdsForActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
    ActiveStorage::Attachment.where(group_id: nil).find_each do |attachment|
      attachment.record.update_attachments!
    end
  end
end
