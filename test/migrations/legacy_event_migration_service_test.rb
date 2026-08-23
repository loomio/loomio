require "test_helper"
require Rails.root.join("db/migrate/support/legacy_event_migration_service")

class LegacyEventMigrationServiceTest < ActiveSupport::TestCase
  test "moves edited event identity from a version to its item" do
    with_legacy_event_schema do
      version = PaperTrail::Version.create!(
        item_type: "Discussion",
        item_id: discussions(:discussion).id,
        event: "update",
        object_changes: { "title" => [ "Before", "After" ] }
      )
      event = LegacyMigratedEventRecord.create!(
        kind: "discussion_edited",
        eventable: version,
        topic_id: topics(:discussion_topic).id,
        custom_fields: {}
      )

      LegacyEventMigrationService.migrate_edited_eventable

      event.reload
      assert_equal "Discussion", event.eventable_type
      assert_equal discussions(:discussion).id, event.eventable_id
      assert_equal version.id, event.custom_fields.fetch("version_id")
      assert_equal [ "title" ], event.custom_fields.fetch("changed_keys")
    ensure
      event&.delete
      version&.delete
    end
  end

  private

  # The service deliberately models the schema at the point where its 2017
  # migration runs. Temporarily expose that shape around the data transform so
  # this test cannot accidentally pass through today's TopicItem associations.
  def with_legacy_event_schema
    connection = ActiveRecord::Base.connection
    connection.rename_table(:topic_items, :events)
    connection.rename_column(:events, :itemable_type, :eventable_type)
    connection.rename_column(:events, :itemable_id, :eventable_id)
    connection.rename_column(:events, :itemable_version_id, :eventable_version_id)
    LegacyMigratedEventRecord.reset_column_information

    yield
  ensure
    if connection&.data_source_exists?(:events)
      connection.rename_column(:events, :eventable_type, :itemable_type)
      connection.rename_column(:events, :eventable_id, :itemable_id)
      connection.rename_column(:events, :eventable_version_id, :itemable_version_id)
      connection.rename_table(:events, :topic_items)
      LegacyMigratedEventRecord.reset_column_information
      TopicItem.reset_column_information
    end
  end
end
