class MigrateVersionsToEventables < ActiveRecord::Migration
  def change
    # cant do it here
    # MigrateEventsService.migrate_edited_eventable
  end
end
