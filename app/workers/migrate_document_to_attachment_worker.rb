class MigrateDocumentToAttachmentWorker
  include Sidekiq::Worker

  PARENT_TYPES = %w[Comment Discussion Group Outcome Poll].freeze

  def perform(doc_id)
    doc = Document.find_by(id: doc_id)
    return unless doc

    parent = parent_for(doc.model_type, doc.model_id)
    if parent.nil?
      drop_doc(doc.id)
      return
    end

    existing_asa = ActiveStorage::Attachment.find_by(record_type: 'Document', record_id: doc.id, name: 'file')
    blob =
      if existing_asa
        existing_asa.blob
      elsif doc.file_file_name.blank? || doc.url.blank?
        drop_doc(doc.id)
        return
      else
        create_blob_from_url(doc) or return
      end

    attach_and_finalize(parent, doc, blob)
  end

  private

  def parent_for(model_type, model_id)
    return nil unless PARENT_TYPES.include?(model_type) && model_id
    model_type.constantize.find_by(id: model_id)
  end

  def attach_and_finalize(parent, doc, blob)
    parent.with_lock do
      effective_filename = doc.file_file_name.presence || blob.filename.to_s

      already_attached = ActiveStorage::Attachment.exists?(record: parent, blob_id: blob.id, name: 'files')
      filename_dup = !already_attached && parent_already_has_filename?(parent, effective_filename)

      unless already_attached || filename_dup
        ActiveStorage::Attachment.create!(record: parent, blob: blob, name: 'files')
      end

      ActiveStorage::Attachment.where(record_type: 'Document', record_id: doc.id).delete_all
      Document.where(id: doc.id).delete_all

      parent.send(:build_attachments)
      parent.update_column(:attachments, parent[:attachments])
    end
  end

  def parent_already_has_filename?(parent, filename)
    parent.files.attachments
      .joins(:blob)
      .where(active_storage_blobs: { filename: filename })
      .exists?
  end

  def create_blob_from_url(doc)
    key = blob_key_from_url(doc.url)
    return nil if key.blank?

    if (existing_blob = ActiveStorage::Blob.find_by(key: key))
      return existing_blob
    end

    metadata = fetch_blob_metadata(key) or return nil

    ActiveStorage::Blob.create!(
      key: key,
      filename: doc.file_file_name,
      content_type: doc.file_content_type.presence || metadata[:content_type],
      byte_size: metadata[:byte_size],
      checksum: metadata[:checksum],
      service_name: ActiveStorage::Blob.service.name.to_s
    )
  rescue ActiveRecord::RecordNotUnique
    ActiveStorage::Blob.find_by(key: key)
  end

  def blob_key_from_url(url)
    URI(url).path.to_s.sub(%r{\A/}, '')
  rescue URI::InvalidURIError
    nil
  end

  def fetch_blob_metadata(key)
    service = ActiveStorage::Blob.service
    return nil unless service.exist?(key)

    case service.class.name
    when 'ActiveStorage::Service::S3Service'
      obj = service.bucket.object(key)
      { byte_size: obj.content_length,
        content_type: obj.content_type,
        checksum: obj.etag.to_s.tr('"', '') }
    when 'ActiveStorage::Service::DiskService'
      path = service.send(:path_for, key)
      { byte_size: File.size(path),
        content_type: nil,
        checksum: OpenSSL::Digest::MD5.file(path).base64digest }
    else
      nil
    end
  rescue => e
    Sidekiq.logger.warn "MigrateDocumentToAttachmentWorker: blob metadata fetch failed for key=#{key}: #{e.class}: #{e.message}"
    nil
  end

  def drop_doc(doc_id)
    ActiveStorage::Attachment.where(record_type: 'Document', record_id: doc_id).delete_all
    Document.where(id: doc_id).delete_all
  end
end
