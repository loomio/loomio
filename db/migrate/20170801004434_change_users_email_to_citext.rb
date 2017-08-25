class ChangeUsersEmailToCitext < ActiveRecord::Migration
  def change
    change_column :users, :email, :citext
  end
end
