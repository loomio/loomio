class AddIndexIndexMembershipsOnUserIdToMemberships < ActiveRecord::Migration
  def change
    add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"
  end
end
