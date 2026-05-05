class DropDocumentsTable < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  PARENT_TYPES = %w[Comment Discussion Group Outcome Poll].freeze

  class LegacyDocument < ActiveRecord::Base
    self.table_name = 'documents'
  end

  def up
    return unless table_exists?(:documents)

    n = LegacyDocument.count
    if n > 0
      say_with_time "Draining #{n} legacy Document records into ActiveStorage attachments" do
        LegacyDocument.find_each(batch_size: 200) { |doc| migrate_doc(doc) }
        remaining = LegacyDocument.count
        if remaining > 0
          raise "documents table still has #{remaining} rows after drain. " \
                "Investigate before re-running this migration."
        end
      end
    end

    drop_table :documents
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def migrate_doc(doc)
    parent = parent_for(doc.model_type, doc.model_id)
    return drop_doc(doc.id) unless parent

    if (existing_asa = ActiveStorage::Attachment.find_by(record_type: 'Document', record_id: doc.id, name: 'file'))
      attach_and_finalize(parent, doc, existing_asa.blob)
      return
    end

    if doc.file_file_name.blank? || doc.url.blank?
      drop_doc(doc.id)
      return
    end

    key = blob_key_from_url(doc.url)
    if key.blank?
      drop_doc(doc.id)
      return
    end

    if (existing_blob = ActiveStorage::Blob.find_by(key: key))
      attach_and_finalize(parent, doc, existing_blob)
      return
    end

    case storage_check(key)
    when :missing
      drop_doc(doc.id)
      return
    when :transient
      raise "Storage check failed for key=#{key} on document #{doc.id}. " \
            "Re-run after the storage backend is reachable."
    end

    metadata = fetch_blob_metadata(key)
    if metadata.nil?
      raise "Failed to fetch blob metadata for key=#{key} on document #{doc.id}."
    end

    blob = create_blob(key, doc, metadata)
    attach_and_finalize(parent, doc, blob)
  end

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
      LegacyDocument.where(id: doc.id).delete_all

      parent.send(:build_attachments)
      parent.update_column(:attachments, parent[:attachments])
    end
  rescue ActiveStorage::IntegrityError => e
    raise "IntegrityError on doc=#{doc.id} parent=#{parent.class.name}##{parent.id} " \
          "blob=#{blob.id} key=#{blob.key.inspect} content_type=#{blob.content_type.inspect} " \
          "checksum=#{blob.checksum.inspect}: #{e.class}"
  end

  def parent_already_has_filename?(parent, filename)
    parent.files.attachments
      .joins(:blob)
      .where(active_storage_blobs: { filename: filename })
      .exists?
  end

  def storage_check(key)
    ActiveStorage::Blob.service.exist?(key) ? :present : :missing
  rescue
    :transient
  end

  def fetch_blob_metadata(key)
    service = ActiveStorage::Blob.service
    case service.class.name
    when 'ActiveStorage::Service::S3Service'
      obj = service.bucket.object(key)
      { byte_size: obj.content_length, content_type: obj.content_type, checksum: obj.etag.to_s.tr('"', '') }
    when 'ActiveStorage::Service::DiskService'
      path = service.send(:path_for, key)
      { byte_size: File.size(path), content_type: nil, checksum: OpenSSL::Digest::MD5.file(path).base64digest }
    else
      nil
    end
  rescue
    nil
  end

  def create_blob(key, doc, metadata)
    ActiveStorage::Blob.create!(
      key: key,
      filename: doc.file_file_name,
      content_type: doc.file_content_type.presence || metadata[:content_type],
      byte_size: metadata[:byte_size],
      checksum: metadata[:checksum],
      # Skip ActiveStorage::AnalyzeJob — the checksum we got from S3 may be a
      # multipart etag (not the file's MD5), which causes verify_integrity_of
      # to raise IntegrityError on download.
      metadata: { 'analyzed' => true },
      service_name: ActiveStorage::Blob.service.name.to_s
    )
  rescue ActiveRecord::RecordNotUnique
    ActiveStorage::Blob.find_by!(key: key)
  end

  def blob_key_from_url(url)
    URI(url).path.to_s.sub(%r{\A/}, '')
  rescue URI::InvalidURIError
    nil
  end

  def drop_doc(doc_id)
    ActiveStorage::Attachment.where(record_type: 'Document', record_id: doc_id).delete_all
    LegacyDocument.where(id: doc_id).delete_all
  end
end
