class ChangeMembersCanInviteMembersToDefaultFalse < ActiveRecord::Migration[6.1]
  def change
    change_column :groups, :members_can_add_members, :boolean, default: false, null: false
  end
end
