class AddGroupToGroupRequest < ActiveRecord::Migration
  def change
    add_column :group_requests, :group_id, :integer
    add_index :group_requests, :group_id
  end
end
