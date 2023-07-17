class AddEnqueueTagsMigrationJob < ActiveRecord::Migration[7.0]
  def up
    MigrateTagsWorker.perform_async
  end
  def down
  end
end
