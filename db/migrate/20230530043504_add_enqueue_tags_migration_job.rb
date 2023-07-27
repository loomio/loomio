class AddEnqueueTagsMigrationJob < ActiveRecord::Migration[7.0]
  def up
    MigrateTagsWorker.perform
  end
  def down
  end
end
