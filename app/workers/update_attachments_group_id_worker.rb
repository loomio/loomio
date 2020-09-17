class UpdateAttachmentsGroupIdWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(record_type, record_id)
    record = record_type.to_s.singularize.classify.constantize.find(record_id)
    if record.respond_to?(:group) && record.group
      record.files.update_all(group_id: record.group.id)
      record.image_files.update_all(group_id: record.group.id)
    end
  end
end
