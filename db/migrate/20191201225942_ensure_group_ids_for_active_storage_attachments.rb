class EnsureGroupIdsForActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
    ActiveStorage::Attachment.where(group_id: nil).find_each do |attachment|
      attachment.update(group_id: attachment.record.group.id) if attachment.record && attachment.record.group
    end
  end
end
