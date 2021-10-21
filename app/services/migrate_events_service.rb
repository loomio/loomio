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
    models = [Group, User, Discussion, Comment, Poll, Stance, Outcome, Document]

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
            puts "#{model.to_s} #{instance.id} " + instance.send("#{attachment}_file_name")
            MigrateAttachmentWorker.perform_async(model.to_s, instance.id, attachment)
          end
        end
      end
    end
    User.where("uploaded_avatar_file_name is not null").update_all(avatar_kind: "uploaded")
  end

  def self.rewrite_inline_images(host = nil)
    ActiveStorage::Attachment.where(name: 'image_files').includes(:record).order('id desc').each do |attachment|
      record = attachment.record
      column_name = names[attachment.record_type]
      next unless record[column_name].present?

      host ||= Regexp.escape ENV['CANONICAL_HOST']
      regex = /https:\/\/#{host}\/rails\/active_storage\/representations\/.*#{Regexp.escape URI.escape(attachment.filename.to_s)}/

      if record[column_name].match?(regex)
        path = Rails.application.routes.url_helpers.rails_representation_path(
                 attachment.representation(HasRichText::PREVIEW_OPTIONS),
                 only_path: true
               )
        puts "updating #{attachment.record_type} #{attachment.record_id}"
        record.update_columns(column_name => record[column_name].gsub(regex, path))
      end
    end
  end

  def self.rewrite_attachment_links
    names.each_pair do |type, col|
      type.constantize.where('attachments != ?', '[]').with_attached_files.each do |record|
        record.update_columns(attachments: record.build_attachments)
      end
    end
  end

  def self.names
    names = {
      'Discussion' => 'description',
      'Comment' => 'body',
      'Poll' => 'details',
      'Outcome' => 'statement',
      'Stance' => 'reason',
      'User' => 'short_bio',
      'Group' => 'description',
    }
  end
end
