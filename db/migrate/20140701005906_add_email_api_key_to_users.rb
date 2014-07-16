class AddEmailAPIKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_api_key, :string
  end
end
