class AddOtherSectorToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :other_sector, :string
  end
end
