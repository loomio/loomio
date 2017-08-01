class ChangeUsersEmailIndexUniqunessConstraint < ActiveRecord::Migration
  def change
    remove_index :users, :email
    add_index :users, :email, name: "index_email_verified", where: '(email_verified is TRUE)'
  end
end
