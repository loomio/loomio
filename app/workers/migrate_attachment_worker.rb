class MigrateAttachmentWorker
  include Sidekiq::Worker

  def perform(record_type, record_id, name)
    model = record_type.constantize.find(record_id)
    paperclip = Paperclip::Attachment.new(name, model)
    model.send(name).attach(io: open(paperclip.url), filename: File.basename(paperclip.url))
  end
end
