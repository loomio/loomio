require_relative "support/legacy_event_migration_service"

class MigrateVersionsToEventablesAttempt2 < ActiveRecord::Migration[4.2]
  def change
    LegacyEventMigrationService.migrate_edited_eventable
  end
end
