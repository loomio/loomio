class MigrateDocumentsToAttachmentsWorker
  include Sidekiq::Worker

  PARENT_TYPES = %w[Comment Discussion Group Outcome Poll].freeze
  BATCH_SIZE = 200

  def perform(after_id = 0)
    docs = Document
      .where('id > ?', after_id)
      .order(:id)
      .limit(BATCH_SIZE)
      .pluck(:id, :model_type, :model_id, :file_file_name, :file_content_type, :url)
    return if docs.empty?

    affected = Hash.new { |h, k| h[k] = Set.new }

    docs.each { |row| migrate_doc(row, affected) }

    rebuild_attachments_json(affected)

    next_after = docs.last.first
    self.class.perform_async(next_after) if Document.where('id > ?', next_after).exists?
  end

  private

  def migrate_doc(row, affected)
    doc_id, model_type, model_id, filename, content_type, url = row
    parent = parent_for(model_type, model_id)

    if parent.nil?
      drop_doc(doc_id)
      return
    end

    if (existing = ActiveStorage::Attachment.find_by(record_type: 'Document', record_id: doc_id, name: 'file'))
      attach_existing_blob(parent, doc_id, existing.blob, filename)
      affected[model_type] << model_id
      return
    end

    if filename.blank? || url.blank?
      drop_doc(doc_id)
      return
    end

    if parent_already_has_filename?(parent, filename)
      delete_doc_and_orphan_asa(doc_id)
      affected[model_type] << model_id
      return
    end

    blob = create_blob_from_url(filename, content_type, url)
    return if blob.nil?

    ActiveRecord::Base.transaction do
      ActiveStorage::Attachment.create!(record: parent, blob: blob, name: 'files')
      delete_doc_and_orphan_asa(doc_id)
    end

    affected[model_type] << model_id
  end

  def attach_existing_blob(parent, doc_id, blob, doc_filename)
    effective_filename = doc_filename.presence || blob.filename.to_s

    if ActiveStorage::Attachment.exists?(record: parent, blob_id: blob.id, name: 'files')
      delete_doc_and_orphan_asa(doc_id)
      return
    end

    if parent_already_has_filename?(parent, effective_filename)
      delete_doc_and_orphan_asa(doc_id)
      return
    end

    ActiveRecord::Base.transaction do
      ActiveStorage::Attachment.create!(record: parent, blob: blob, name: 'files')
      delete_doc_and_orphan_asa(doc_id)
    end
  end

  def parent_for(model_type, model_id)
    return nil unless PARENT_TYPES.include?(model_type) && model_id
    model_type.constantize.find_by(id: model_id)
  end

  def parent_already_has_filename?(parent, filename)
    parent.files.attachments
      .joins(:blob)
      .where(active_storage_blobs: { filename: filename })
      .exists?
  end

  def create_blob_from_url(filename, content_type, url)
    key = blob_key_from_url(url)
    return nil if key.blank?

    if (existing_blob = ActiveStorage::Blob.find_by(key: key))
      return existing_blob
    end

    metadata = fetch_blob_metadata(key) or return nil

    ActiveStorage::Blob.create!(
      key: key,
      filename: filename,
      content_type: content_type.presence || metadata[:content_type],
      byte_size: metadata[:byte_size],
      checksum: metadata[:checksum],
      service_name: ActiveStorage::Blob.service.name.to_s
    )
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
    Sidekiq.logger.warn "MigrateDocumentsToAttachmentsWorker: blob metadata fetch failed for key=#{key}: #{e.class}: #{e.message}"
    nil
  end

  def delete_doc_and_orphan_asa(doc_id)
    ActiveStorage::Attachment.where(record_type: 'Document', record_id: doc_id).delete_all
    Document.where(id: doc_id).delete_all
  end

  def drop_doc(doc_id)
    ActiveStorage::Attachment
      .where(record_type: 'Document', record_id: doc_id)
      .find_each(&:purge_later)
    Document.where(id: doc_id).delete_all
  end

  def rebuild_attachments_json(affected)
    affected.each do |model_type, ids|
      klass = model_type.constantize
      klass.where(id: ids.to_a).with_attached_files.find_each do |parent|
        parent.send(:build_attachments)
        parent.update_column(:attachments, parent[:attachments])
      end
    end
  end
end
