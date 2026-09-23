class RenameGroupsArchivedAtToDiscardedAt < ActiveRecord::Migration[8.1]
  def up
    rename_column :groups, :archived_at, :discarded_at
    if index_name_exists?(:groups, :index_groups_on_archived_at)
      rename_index :groups, :index_groups_on_archived_at, :index_groups_on_discarded_at
    elsif !index_name_exists?(:groups, :index_groups_on_discarded_at)
      add_index :groups, :discarded_at, where: "discarded_at IS NULL"
    end
    add_column :groups, :discarded_by, :integer
  end

  def down
    remove_column :groups, :discarded_by
    rename_column :groups, :discarded_at, :archived_at
    if index_name_exists?(:groups, :index_groups_on_discarded_at)
      rename_index :groups, :index_groups_on_discarded_at, :index_groups_on_archived_at
    end
  end
end
