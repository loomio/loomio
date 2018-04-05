class AddTokenToMemberships < ActiveRecord::Migration[5.1]
  def change
    add_column :memberships, :token, :string
    add_index :memberships, :token, unique: true
  end
end
