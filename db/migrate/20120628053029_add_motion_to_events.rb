class AddMotionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :motion_id, :integer
    add_index :events, :motion_id
  end
end
