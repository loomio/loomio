class AddArchivedAtToComments < ActiveRecord::Migration
  def change
    add_column :comments, :archived_at, :datetime
  end
end
