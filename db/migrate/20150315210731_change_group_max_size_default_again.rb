class ChangeGroupMaxSizeDefaultAgain < ActiveRecord::Migration
  def change
    change_column :groups, :max_size, :integer, default: 200
  end
end
