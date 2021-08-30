class MigrateAttachmentWorker
  include Sidekiq::Worker

  def perform(record_type, record_id, name)
    model = record_type.constantize.find(record_id)
    paperclip = Paperclip::Attachment.new(name, model)
    if paperclip.url == '/uploaded_avatars/original/missing.png'
      model.update_columns("#{name}_file_name": nil)
    else
      model.send(name).attach(io: open(paperclip.url), filename: File.basename(paperclip.url))
    end
  end
end
