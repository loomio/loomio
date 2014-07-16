class ChangeGroupMaxSizeDefault < ActiveRecord::Migration
  def change
    change_column :groups, :max_size, :integer, default: 1000
    Group.update_all(max_size: 5000)
  end
end
