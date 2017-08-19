class AddParentIdOnEvents < ActiveRecord::Migration
  def change
    add_column :events, :parent_id, :integer
    # add_column :events, :children_count, :integer, default: 0, null: false
    # TODO use async method to add this
    add_index :events, :parent_id
  end
end
