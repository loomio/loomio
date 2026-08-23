# Historical data transforms for migrations that ran while the timeline table
# and polymorphic association were still named events/eventable. Keeping these
# operations here prevents current TopicItem models from redefining old schema.
class LegacyMigratedEventRecord < ActiveRecord::Base
  self.table_name = "events"

  belongs_to :eventable, polymorphic: true
  has_many :notifications,
           class_name: "LegacyMigratedNotificationRecord",
           foreign_key: :event_id,
           dependent: :delete_all
end

class LegacyMigratedNotificationRecord < ActiveRecord::Base
  self.table_name = "notifications"
end

module LegacyEventMigrationService
  CONTENT_COLUMNS = {
    "Discussion" => "description",
    "Comment" => "body",
    "Poll" => "details",
    "Outcome" => "statement",
    "Stance" => "reason",
    "User" => "short_bio",
    "Group" => "description"
  }.freeze

  def self.migrate_edited_eventable
    LegacyMigratedEventRecord.where(
      kind: %w[poll_edited discussion_edited],
      eventable_type: "PaperTrail::Version"
    ).find_each do |event|
      version = event.eventable
      event.update_columns(
        eventable_type: version.item_type,
        eventable_id: version.item_id,
        custom_fields: {
          version_id: version.id,
          changed_keys: Hash(version.object_changes).keys
        }
      )
    end

    LegacyMigratedEventRecord
      .joins("LEFT OUTER JOIN polls ON events.eventable_id = polls.id")
      .where(eventable_type: "Poll", polls: { id: nil })
      .destroy_all
  end

  def self.rewrite_inline_images(host = nil)
    ActiveStorage::Attachment.where(name: "image_files").includes(:record).order(id: :desc).each do |attachment|
      record = attachment.record
      column_name = CONTENT_COLUMNS[attachment.record_type]
      next unless column_name && record[column_name].present?

      host ||= Regexp.escape(ENV["CANONICAL_HOST"])
      filename = Regexp.escape(URI::DEFAULT_PARSER.escape(attachment.filename.to_s))
      regex = %r{https://#{host}/rails/active_storage/representations/.*#{filename}}
      next unless record[column_name].match?(regex)

      path = Rails.application.routes.url_helpers.rails_representation_path(
        attachment.representation(HasRichText::PREVIEW_OPTIONS),
        only_path: true
      )
      record.update_columns(column_name => record[column_name].gsub(regex, path))
    end
  end

  def self.rewrite_attachment_links
    CONTENT_COLUMNS.each_pair do |type, column_name|
      type.constantize.where("attachments != ?", "[]").with_attached_files.find_each do |record|
        record.update_columns(attachments: record.build_attachments)
      end
    end
  end
end
