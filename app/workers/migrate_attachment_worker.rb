class MigrateAttachmentWorker
  include Sidekiq::Worker

  def perform(record_type, record_id, name)
    instance = record_type.constantize.find(record_id)
    file = Net::HTTP.get(URI(instance.send(name).url))
    checksum = Digest::MD5.base64digest(file)
    size = file.size

    return if ActiveStorage::Blob.where(filename: instance.send("#{name}_file_name"),
                                        byte_size: size).exists?

    return if ActiveStorage::Attachment.where(record_type: instance.class.to_s,
                                              record_id: instance.id,
                                              name: name).exists?
    instance.class.transaction do
      blob = ActiveStorage::Blob.create!(
        key: SecureRandom.uuid,
        filename: instance.send("#{name}_file_name"),
        content_type: instance.send("#{name}_content_type"),
        metadata: {},
        byte_size: size,
        checksum: checksum,
        created_at: instance.updated_at
      )

      ActiveStorage::Attachment.import [ActiveStorage::Attachment.new( name: name, record_type: record_type, record_id: record_id, blob_id: blob.id, created_at: instance.updated_at )]
    end
  end
end
