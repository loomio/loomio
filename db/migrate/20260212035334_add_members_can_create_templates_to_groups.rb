class AddMembersCanCreateTemplatesToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :members_can_create_templates, :boolean, default: false, null: false
  end
end
