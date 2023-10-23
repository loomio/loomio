class RenameMembershipsArchivedAtToRevokedAt < ActiveRecord::Migration[7.0]
  def change
    rename_column :memberships, :archived_at, :revoked_at
    add_column :memberships, :revoker_id, :integer
  end
end
