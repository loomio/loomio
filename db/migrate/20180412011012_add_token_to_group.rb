class AddTokenToGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :token, :string
    add_index :groups, :token, unique: true
  end
end
