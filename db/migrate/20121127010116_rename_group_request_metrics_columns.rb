class RenameGroupRequestMetricsColumns < ActiveRecord::Migration
  def up
    rename_column :group_requests, :sectors, :sectors_metric
    rename_column :group_requests, :other_sector, :other_sectors_metric
  end

  def down
    rename_column :group_requests, :sectors_metric, :sectors
    rename_column :group_requests, :other_sectors_metric, :other_sector
  end
end
