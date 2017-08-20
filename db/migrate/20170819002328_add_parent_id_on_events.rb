class AddParentIdOnEvents < ActiveRecord::Migration
  def change
    add_column :events, :parent_id, :integer
    # TODO use async method to add this?
    add_index :events, :parent_id
  end
end
