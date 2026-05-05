class MigrateDocumentsToAttachmentsWorker
  include Sidekiq::Worker

  BATCH_SIZE = 500

  def perform(after_id = 0)
    doc_ids = Document
      .where('id > ?', after_id)
      .order(:id)
      .limit(BATCH_SIZE)
      .pluck(:id)
    return if doc_ids.empty?

    doc_ids.each { |id| MigrateDocumentToAttachmentWorker.perform_async(id) }

    self.class.perform_async(doc_ids.last) if Document.where('id > ?', doc_ids.last).exists?
  end
end
