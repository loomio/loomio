class MigrateAttachmentService
  def self.migrate!(attachments: Attachment.none)
    attachments.unmigrated.find_each(batch_size: 100) do |att|
      case att.attachable_type
      when "Discussion"
        Document.find_or_create_by(
          author: att.user,
          model:  att.attachable,
          url:    att.url,
          title:  att.filename
        )
      end
      att.update_attribute :migrated_to_document, true
    end
  end
end
