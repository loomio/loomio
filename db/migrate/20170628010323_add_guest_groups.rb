class AddGuestGroups < ActiveRecord::Migration
  def change
    add_column :groups, :type, :string, default: "FormalGroup", null: false
    add_column :polls, :guest_group_id, :integer
    change_column :groups, :discussion_privacy_options, :string, default: 'private_only', null: false
    change_column :groups, :membership_granted_upon, :string, default: 'approval', null: false
  end
end
