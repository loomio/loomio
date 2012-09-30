class AddCannotContributeToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :cannot_contribute, :boolean, default: false
  end
end
