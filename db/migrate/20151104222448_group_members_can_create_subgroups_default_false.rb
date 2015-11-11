class GroupMembersCanCreateSubgroupsDefaultFalse < ActiveRecord::Migration
  def change
    change_column :groups, :members_can_create_subgroups, :boolean, default: false, null: false
  end
end
