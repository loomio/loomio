class AddIndexIndexMembershipsOnGroupIdToMemberships < ActiveRecord::Migration
  def change
    add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  end
end
