class MembershipsRenameLastViewedAtToGroupLastViewedAt < ActiveRecord::Migration
  def change
    rename_column :memberships, :last_viewed_at, :group_last_viewed_at
  end
end
