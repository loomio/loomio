class InlineImageAttachmentRepairService
  RECORD_CLASSES = [
    Comment,
    Discussion,
    DiscussionTemplate,
    Group,
    Outcome,
    Poll,
    PollTemplate,
    Stance,
    User
  ].freeze

  def self.run(dry_run: true, batch_size: 500, progress: nil)
    stats = stats_new(dry_run: dry_run)
    blob_ids_missing = {}

    RECORD_CLASSES.each do |record_class|
      records_with_inline_images(record_class).find_each(batch_size: batch_size) do |record|
        result = repair_record(record, dry_run: dry_run)
        stats[:records_scanned] += 1
        stats[:records_repaired] += 1 if result[:attachment_links_missing].positive?
        stats[:attachment_links_missing] += result[:attachment_links_missing]
        stats[:signed_ids_unresolved] += result[:signed_ids_unresolved]
        result[:blob_ids_missing].each { |blob_id| blob_ids_missing[blob_id] = true }

        if progress && (stats[:records_scanned] % 1_000).zero?
          progress.call("Scanned #{stats[:records_scanned]} records; " \
                        "found #{stats[:attachment_links_missing]} missing attachment links")
        end
      end
    end

    stats[:blobs_missing] = blob_ids_missing.length
    stats[:blob_bytes_missing] = ActiveStorage::Blob.where(id: blob_ids_missing.keys).sum(:byte_size)
    stats
  end

  def self.repair_record(record, dry_run: true)
    signed_ids = record.class.rich_text_fields.flat_map do |field|
      HasRichText.inline_blob_signed_ids(record[field])
    end.uniq
    blobs_resolved = signed_ids.filter_map { |signed_id| ActiveStorage::Blob.find_signed(signed_id) }
    blobs = blobs_resolved.uniq(&:id)
    blob_ids_attached = ActiveStorage::Attachment.where(
      record: record,
      name: "image_files",
      blob_id: blobs.map(&:id)
    ).pluck(:blob_id)
    blobs_missing = blobs.reject { |blob| blob_ids_attached.include?(blob.id) }

    unless dry_run
      group_id = group_id_for(record)
      blobs_missing.each { |blob| create_attachment(record, blob, group_id) }
    end

    {
      attachment_links_missing: blobs_missing.length,
      blob_ids_missing: blobs_missing.map(&:id),
      signed_ids_unresolved: signed_ids.length - blobs_resolved.length
    }
  end

  def self.records_with_inline_images(record_class)
    fields = record_class.rich_text_fields
    condition = fields.map { |field| "#{record_class.connection.quote_column_name(field)} LIKE :path" }.join(" OR ")
    record_class.where(condition, path: "%/rails/active_storage/%")
  end

  def self.create_attachment(record, blob, group_id)
    record.class.no_touching do
      ActiveStorage::Attachment.find_or_create_by!(
        record: record,
        name: "image_files",
        blob: blob
      ) do |attachment|
        attachment.group_id = group_id
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # Another idempotent repair created the same attachment concurrently.
  end

  def self.group_id_for(record)
    return record.id if record.is_a?(Group)
    return record.group_id if record.respond_to?(:group_id)
    return record.group.id if record.respond_to?(:group) && record.group
  rescue ActiveRecord::RecordNotFound, NoMethodError
    nil
  end

  def self.stats_new(dry_run:)
    {
      dry_run: dry_run,
      records_scanned: 0,
      records_repaired: 0,
      attachment_links_missing: 0,
      blobs_missing: 0,
      blob_bytes_missing: 0,
      signed_ids_unresolved: 0
    }
  end

  private_class_method :records_with_inline_images, :create_attachment, :group_id_for, :stats_new
end
