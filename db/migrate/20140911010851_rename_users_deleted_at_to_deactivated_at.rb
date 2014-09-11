class RenameUsersDeletedAtToDeactivatedAt < ActiveRecord::Migration
  def change
    rename_column :users, :deleted_at, :deactivated_at
  end
end
