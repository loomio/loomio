class AddStatusToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :status, :string
  end
end
