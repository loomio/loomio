class AddGuestGroups < ActiveRecord::Migration
  def change
    add_column :groups, :type, :string, default: "Group", null: false
    add_column :polls, :guest_group_id, :integer
  end
end
