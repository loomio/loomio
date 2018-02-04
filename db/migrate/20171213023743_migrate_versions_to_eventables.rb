class MigrateVersionsToEventables < ActiveRecord::Migration[4.2]
  def change
    # cant do it here
    # MigrateEventsService.migrate_edited_eventable
  end
end
