class EnsureGroupIdsForActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
    ActiveStorage::Attachment.where(group_id: nil).find_each do |attachment|
      if attachment.record && attachment.record.respond_to?(:group) && attachment.record.group
        attachment.update(group_id: attachment.record.group.id)
      end
    end
  end
end
