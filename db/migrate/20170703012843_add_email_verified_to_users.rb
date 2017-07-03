class AddEmailVerifiedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_verified, :boolean, null: false, default: true
    change_column :users, :email_verified, :boolean, null: false, default: false
  end
end
