class AddArchivedAtToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :archived_at, :timestamp, :default => nil
  end
end
