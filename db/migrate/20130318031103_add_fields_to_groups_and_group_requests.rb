class AddFieldsToGroupsAndGroupRequests < ActiveRecord::Migration
  def change
    rename_column :group_requests, :sectors_metric, :sectors
    rename_column :group_requests, :other_sectors_metric, :other_sector
    add_column :group_requests, :admin_name, :string
    add_column :group_requests, :country_name, :string

    rename_column :groups, :sectors_metric, :sectors
    rename_column :groups, :other_sectors_metric, :other_sector
    add_column :groups, :country_name, :string
  end
end
