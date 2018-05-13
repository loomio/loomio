class MigrateVersionsToEventablesAttempt2 < ActiveRecord::Migration[4.2]
  def change
    MigrateEventsService.migrate_edited_eventable
  end
end
