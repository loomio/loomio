class AddUserToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :user_id, :integer
  end
end
