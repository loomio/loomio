class MigrateTemplateDiscussionsToDiscussionTemplates < ActiveRecord::Migration[7.0]
  def change
    ConvertDiscussionTemplatesWorker.perform_async(wait: 5.minutes)
  end
end
