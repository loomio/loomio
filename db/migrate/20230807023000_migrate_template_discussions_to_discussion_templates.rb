class MigrateTemplateDiscussionsToDiscussionTemplates < ActiveRecord::Migration[7.0]
  def change
    ConvertDiscussionTemplatesWorker.new.perform
  end
end
