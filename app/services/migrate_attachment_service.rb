require 'benchmark'

class MigrateAttachmentService
  def self.migrate!(attachments: Attachment.none)
    Benchmark.realtime do
      new_docs = []
      attachments.unmigrated.find_each(batch_size: 1000) do |att|
        new_docs << Document.new(
          author_id:      att.user_id,
          model_id:       att.attachable_id,
          model_type:     att.attachable_type,
          url:            att.url,
          thumb_url:      (att.file.url(:thumb)  if att.is_an_image?),
          web_url:        (att.file.url(:thread) if att.is_an_image?),
          file_file_name: att.filename,
          title:          att.filename,
          created_at:     att.created_at
        ).tap(&:set_metadata)

        if new_docs.length >= 1000
          Document.import new_docs
          new_docs.clear
        end
      end
      Document.import new_docs
      attachments.update_all(migrated_to_document: true)
    end
  end
end
