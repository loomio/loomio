class MigrateVersionsToEventablesAttempt2 < ActiveRecord::Migration
  def change
    MigrateEventsService.migrate_edited_eventable
  end
end
