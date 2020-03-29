class AddTokenToStances < ActiveRecord::Migration[5.2]
  def change
    add_column :stances, :token, :string
    add_index :stances, :token, unique: true
  end
end
