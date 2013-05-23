class AddApprovedByToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :approved_by_id, :integer
  end
end
