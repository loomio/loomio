class AddGroupsCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :category, :string
  end
end
