class FixTemplateIdOnDiscussions < ActiveRecord::Migration[7.0]
  def change
    remove_column :polls, :source_template_id
    remove_column :discussions, :source_template_id
    remove_column :discussion_templates, :source_template_id
    add_column :discussions, :discussion_template_id, :integer
    add_column :discussions, :discussion_template_key, :string
  end
end
