class AddHandleToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :handle, :string
    add_index :groups, :handle, unique: true
  end
end
