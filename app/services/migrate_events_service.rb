module MigrateEventsService
  def self.migrate_edited_eventable
    Event.where(kind: ['poll_edited', 'discussion_edited'] ,
                eventable_type: "PaperTrail::Version").find_each do |event|
      version = event.eventable
      event.update_columns(eventable_type: version.item_type,
                             eventable_id: version.item_id,
                             custom_fields: {version_id: version.id,
                                             changed_keys: Hash(version.object_changes).keys})


    end
    Event.joins("LEFT OUTER JOIN polls on events.eventable_id = polls.id").where(eventable_type: "Poll").where("polls.id is null").destroy_all
  end

  def self.migrate_paperclip
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    models.each do |model|
      attachments = model.column_names.map do |c|
        if c =~ /(.+)_file_name$/
          $1
        end
      end.compact

      next if attachments.blank?

      attachments.each do |attachment|
        model.where("#{attachment}_file_name is not null").send("with_attached_#{attachment}").find_each.each do |instance|
          if instance.send(attachment).attachment.nil?
            puts "#{instance.class} #{instance.id} " + instance.send("#{attachment}_file_name")
            MigrateAttachmentWorker.perform_async(instance.class.to_s, instance.id, attachment)
          end
        end
      end
    end
  end
end
