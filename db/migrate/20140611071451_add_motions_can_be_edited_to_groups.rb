class AddMotionsCanBeEditedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :motions_can_be_edited, :boolean, default: true, null: false
  end
end
