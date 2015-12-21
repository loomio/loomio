class MembersCanAddMembersDefaultTrue < ActiveRecord::Migration
  def change
    remove_column :groups, :members_invitable_by
    change_column :groups, :members_can_add_members, :boolean, default: true, null: false
  end
end
