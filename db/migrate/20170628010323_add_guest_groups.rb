class AddGuestGroups < ActiveRecord::Migration
  def change
    add_column :groups, :guest, :boolean, default: false, null: false
    add_column :polls, :guest_group_id, :integer
    # add_column :users, :email_verified, default: false, null: false
  end
end
