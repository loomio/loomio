class AddChangesToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :object_changes, :jsonb
  end
end
