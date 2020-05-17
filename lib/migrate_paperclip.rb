# require_relative 'lib/migrate_paperclip'
# MigratePaperclip.new.up
class MigratePaperclip
  require 'open-uri'

  def up
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    models.each do |model|
      attachments = model.column_names.map do |c|
        if c =~ /(.+)_file_name$/
          $1
        end
      end.compact

      next if attachments.blank?

      model.find_each.each do |instance|
        attachments.each do |attachment|
          next if instance.send(attachment).path.blank? or ActiveStorage::Attachment.where(record_type: instance.class.to_s, record_id: instance.id, name: attachment).exists?
          MigrateAttachmentWorker.perform_async(instance.class.to_s, instance.id, attachment)
        end
      end
    end
  end
end
