class UpdateAttachmentsGroupId < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    ActiveStorage::Attachment.where(group_id: nil).find_each do |a|
      next unless a && a.record
      UpdateAttachmentsGroupIdWorker.perform_async(a.record.class.to_s, a.record.id)
    end
  end
end
