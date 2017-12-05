class MigrateAttachmentService
  def self.migrate!(attachments: Attachment.none)
    attachments.unmigrated.find_each(batch_size: 100) do |att|
      Document.create(
        author:     att.user,
        model:      att.attachable,
        url:        att.url,
        # thumb_url:  (att.file.url(:thumb)  if att.is_an_image?),
        # web_url:    (att.file.url(:thread) if att.is_an_image?),
        title:      att.filename,
        created_at: att.created_at
      )
      att.update_attribute :migrated_to_document, true
    end
  end
end
