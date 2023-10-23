class AddPublicBooleanToDiscussionTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :discussion_templates, :public, :boolean, default: false, null: false
  end
end
