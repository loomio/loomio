class AddParentIdOnEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :parent_id, :integer
    add_index :events, :parent_id, where: "(parent_id IS NOT NULL)"
  end
end
