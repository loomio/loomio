class MigrateAttachmentWorker
  include Sidekiq::Worker

  def perform(record_type, record_id, name)
    model = record_type.constantize.find(record_id)

    if model.send(name).attachment.nil?
      paperclip = Paperclip::Attachment.new(name, model)
      model.send(name).attach(io: URI.open(paperclip.url), filename: File.basename(paperclip.url))
    end
  end
end
