class AddIndexToMembershipRequests < ActiveRecord::Migration
  def change
    add_index :membership_requests, [:group_id, :response]
  end
end
