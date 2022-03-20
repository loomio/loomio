class DownloadAttachmentWorker
  include Sidekiq::Worker

  def perform(record, new_id)
  	GroupExportService.download_attachment(record, new_id)
  end
end
