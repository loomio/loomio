class AddParentIdIndexToEvents < ActiveRecord::Migration[5.1]
  def change
    add_index :events, :parent_id
  end
end
