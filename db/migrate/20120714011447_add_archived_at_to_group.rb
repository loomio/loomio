class AddArchivedAtToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :archived_at, :timestamp, :default => nil
  end
end
