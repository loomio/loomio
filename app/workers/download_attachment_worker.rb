class DownloadAttachmentWorker
  include Sidekiq::Worker

  def perform(host: ,
							record_type: ,
							record_id: ,
							old_record_id: ,
							filename: ,
							content_type: ,
							url: )
  	GroupExportService.download_attachent(
			host: host,
	    record_type: record_type,
	    record_id: record_id,
	    old_record_id: old_record_id,
	    filename: filename,
	    content_type: content_type,
	    url: url
    )
  end
end
