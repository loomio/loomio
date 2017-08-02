class AddUniqueIndexUsersEmailVerified < ActiveRecord::Migration
  def change
    remove_index :users, name: 'index_email_verified'
    add_index :users, :email
    add_index :users, :email, name: :email_verified_and_unique, where: "(email_verified IS TRUE)", unique: true
  end
end
