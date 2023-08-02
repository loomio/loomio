class RenameTemplateDiscussionsCount < ActiveRecord::Migration[7.0]
  def change
    rename_column :groups, :template_discussions_count, :discussion_templates_count
  end
end
