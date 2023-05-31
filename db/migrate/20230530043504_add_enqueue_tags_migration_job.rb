class AddEnqueueTagsMigrationJob < ActiveRecord::Migration[7.0]
  def change
    MigrateTagsWorker.perform_async
  end
end
