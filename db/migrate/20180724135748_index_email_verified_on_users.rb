class IndexEmailVerifiedOnUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email_verified
  end
end
