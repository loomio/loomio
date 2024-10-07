class AllowUserEmailNil < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :email, :citext, null: true
  end
end
