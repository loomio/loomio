class AddAPIKeyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :api_key, :string
    add_index :users, :api_key
  end
end
