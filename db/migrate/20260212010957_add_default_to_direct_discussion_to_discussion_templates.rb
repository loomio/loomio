class AddDefaultToDirectDiscussionToDiscussionTemplates < ActiveRecord::Migration[8.0]
  def change
    add_column :discussion_templates, :default_to_direct_discussion, :boolean, default: false, null: false
  end
end
