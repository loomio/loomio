class AddUnsubscribeTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unsubscribe_token, :string
    add_index :users, :unsubscribe_token, unique: true
  end
end
