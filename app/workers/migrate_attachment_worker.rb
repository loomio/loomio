class MigrateAttachmentWorker
  include Sidekiq::Worker

  def perform(record_type, record_id, name)
    model = record_type.constantize.find(record_id)
    paperclip = Paperclip::Attachment.new(name, model)
    if paperclip.url == '/uploaded_avatars/original/missing.png'
      model.update_columns("#{name}_file_name": nil)
    else
      if ENV['AWS_ACCESS_KEY_ID']
        model.send(name).attach(io: open(paperclip.url), filename: File.basename(paperclip.url))
      else
        model.send(name).attach(io: open(paperclip.path), filename: File.basename(paperclip.path))
      end
    end
  rescue OpenURI::HTTPError
    model.update_columns("#{name}_file_name": nil)
  end
end
