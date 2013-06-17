class AddDeletedAtToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :is_deleted, :boolean, :default => false, :null => false
    add_index :discussions, :is_deleted
  end
end
