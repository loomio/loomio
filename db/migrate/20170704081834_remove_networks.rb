class RemoveNetworks < ActiveRecord::Migration
  def change
    drop_table :networks
    drop_table :network_memberships
    drop_table :network_membership_requests
  end
end
