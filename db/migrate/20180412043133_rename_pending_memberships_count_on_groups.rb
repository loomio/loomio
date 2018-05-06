class RenamePendingMembershipsCountOnGroups < ActiveRecord::Migration[5.1]
  def change
    rename_column :groups, :pending_invitations_count, :pending_memberships_count
  end
end
