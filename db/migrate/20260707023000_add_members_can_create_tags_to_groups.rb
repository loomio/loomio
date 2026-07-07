class AddMembersCanCreateTagsToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :members_can_create_tags, :boolean, default: true, null: false
  end
end
