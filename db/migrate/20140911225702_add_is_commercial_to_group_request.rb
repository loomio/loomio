class AddIsCommercialToGroupRequest < ActiveRecord::Migration
  def change
    add_column :group_requests, :is_commercial, :boolean
  end
end
