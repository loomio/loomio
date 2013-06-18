class AddFullNameToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :full_name, :string
    add_index :groups, :full_name
  end
end
