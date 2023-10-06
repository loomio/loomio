class AddEnqueueTagsMigrationJob < ActiveRecord::Migration[7.0]
  def up
    MigrateTagsWorker.new.perform
  end
  def down
  end
end
