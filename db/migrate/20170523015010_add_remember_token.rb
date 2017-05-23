class AddRememberToken < ActiveRecord::Migration
  def change
    add_column :users, :remember_token, :string, null: true
  end
end
