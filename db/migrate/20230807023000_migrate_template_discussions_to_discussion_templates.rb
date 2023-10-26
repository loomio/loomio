class MigrateTemplateDiscussionsToDiscussionTemplates < ActiveRecord::Migration[7.0]
  def change
    ConvertDiscussionTemplatesWorker.perform_later
  end
end
