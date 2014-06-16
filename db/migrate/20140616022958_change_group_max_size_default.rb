class ChangeGroupMaxSizeDefault < ActiveRecord::Migration
  def change
    change_column :groups, :max_size, :integer, default: 1000
  end
end
