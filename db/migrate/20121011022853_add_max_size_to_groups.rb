class AddMaxSizeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :max_size, :integer
  end
end
