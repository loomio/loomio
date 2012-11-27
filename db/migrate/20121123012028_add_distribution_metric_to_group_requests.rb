class AddDistributionMetricToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :distribution_metric, :integer
  end
end
