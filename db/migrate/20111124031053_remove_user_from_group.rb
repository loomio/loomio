class RemoveUserFromGroup < ActiveRecord::Migration
  def up
    remove_column :groups, :user_id
  end

  def down
    add_column :groups, :user_id, :integer
  end
end
