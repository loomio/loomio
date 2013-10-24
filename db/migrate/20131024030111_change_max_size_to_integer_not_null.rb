class ChangeMaxSizeToIntegerNotNull < ActiveRecord::Migration
  def up
    Group.where(max_size: nil).update_all(max_size: 300)
    change_column :groups, :max_size, :integer, null: false, default: 300
  end

  def down
    change_column :groups, :max_size, :integer, null: true, default: 300
  end
end
