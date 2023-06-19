class AttachDocumentWorker
  include Sidekiq::Worker

  def perform(document_id)
    d = Document.find(document_id)
    return if d.file.attached?
    s3 = ActiveStorage::Blob.service
    path = URI(d.url).path.gsub("/attachments", "attachments")
    obj = s3.bucket.object(path)
    params = {filename: obj.key, content_type: obj.content_type, byte_size: obj.size, checksum: obj.etag.gsub('"',"") }
    blob = ActiveStorage::Blob.create_before_direct_upload!(**params)
    blob.key = obj.key
    d.file.attach(blob)
  end
end
