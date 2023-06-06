class MigratePollTemplates < ActiveRecord::Migration[7.0]
  def up
    MigratePollTemplatesWorker.perform_async
  end
  
  def down
  end
end
