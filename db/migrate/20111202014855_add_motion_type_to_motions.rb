class AddMotionTypeToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :motion_type, :string, default: 'proposal'
  end
end
