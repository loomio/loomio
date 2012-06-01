class AddHideMembersToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :hide_members, :boolean, :default => false
  end

  def down
    remove_column :groups, :hide_members
  end
end
