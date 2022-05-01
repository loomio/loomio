class AddDiscussionTemplatesCountToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :template_discussions_count, :integer, default: 0, null: false
    add_index :discussions, :template, where: "(template IS TRUE)"
  end
end
