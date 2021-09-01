class MigratePaperclip
  def up
    Rails.application.eager_load!
    MigrateEventsService.migrate_paperclip
  end
end
