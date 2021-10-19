class RerunPaperclipMigration < ActiveRecord::Migration[6.1]
  def change
    MigrateEventsService.migrate_paperclip
  end
end
