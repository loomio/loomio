class AppendTranscriptWorker
  include Sidekiq::Worker

  def perform(blob_id)
    blob = ActiveStorage::Blob.find(blob_id)

    text = blob.metadata['text']
    blob.attachments.each do |attachment|
      record = attachment.record
      record.body = record.body + "<p>#{text}</p>"
      record.save!
      MessageChannelService.publish_models(Array(record), group_id: record.group_id)
    end
  end
end
