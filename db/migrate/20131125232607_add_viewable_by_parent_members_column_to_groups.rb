class AddViewableByParentMembersColumnToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :viewable_by_parent_members, :boolean
    Group.reset_column_information
    Group.where(privacy: 'parent_group_members').update_all("privacy = 'secret', viewable_by_parent_members = TRUE")
  end

  def down
    Group.where(viewable_by_parent_members: true).update_all("privacy = 'parent_group_members'")
    remove_column :groups, :viewable_by_parent_members
  end
end
