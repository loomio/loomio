class AttachmentPermissionService
  # Check additions before assigning files: Active Storage can save attachments
  # immediately on persisted records. Existing files and media may be retained or
  # removed after a thread is restricted, including during a switch of editor mode.
  def self.authorize!(record:, actor:, params: nil)
    topic = record.topic
    return unless topic.attachments_admin_only?
    return if actor.can?(:attach_files, topic)

    params ||= record.attributes.merge(files: record.files.blobs.to_a, image_files: record.image_files.blobs.to_a)
    params = params.to_h.with_indifferent_access
    existing = record.persisted? ? record.class.find(record.id) : record.class.new
    existing_blob_ids = existing.files.blobs.ids + existing.image_files.blobs.ids

    additions = %i[files image_files].any? do |name|
      Array(params[name]).compact_blank.any? do |attachable|
        blob = attachable.is_a?(String) ? ActiveStorage::Blob.find_signed!(attachable) : attachable
        !blob.is_a?(ActiveStorage::Blob) || !existing_blob_ids.include?(blob.id)
      end
    end
    additions ||= record.class.rich_text_fields.any? do |field|
      next false unless params.key?(field) || params.key?("#{field}_format")

      format = params.fetch("#{field}_format", record.public_send("#{field}_format"))
      text = params.fetch(field, record[field])
      (media_sources(text, format) - media_sources(existing[field], existing.public_send("#{field}_format"))).any?
    end
    return unless additions

    raise CanCan::AccessDenied.new(I18n.t('errors.attachments_admin_only'), :attach_files, topic)
  end

  def self.authorize_topic_settings!(topic:, params:, actor:)
    return unless params.key?(:attachments_admin_only)
    return if ActiveModel::Type::Boolean.new.cast(params[:attachments_admin_only]) == topic.attachments_admin_only

    actor.ability.authorize! :update, topic
  end

  def self.media_sources(text, format)
    html = format == 'md' ? MarkdownService.render_html(text.to_s) : text.to_s
    Nokogiri::HTML.fragment(html).css('img, video, audio, source').flat_map do |node|
      %w[src poster srcset].filter_map { |attribute| node[attribute].presence }
    end
  end
  private_class_method :media_sources
end
