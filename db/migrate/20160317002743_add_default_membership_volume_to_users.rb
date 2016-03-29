class AddDefaultMembershipVolumeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_membership_volume, :integer, null: false, default: 3
  end
end
