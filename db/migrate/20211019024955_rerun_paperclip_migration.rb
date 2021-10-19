class RerunPaperclipMigration < ActiveRecord::Migration[6.1]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    MigrateEventsService.migrate_paperclip
  end
end
