class GroupRequestsPopulateDistributionMetric < ActiveRecord::Migration
  class GroupRequest < ActiveRecord::Base
  end

  def up
    GroupRequest.where(:distribution_metric => nil).
                  update_all(:distribution_metric => -1)
  end

  def down
    GroupRequest.where(:distribution_metric => -1).
                  update_all(:distribution_metric => nil)
  end
end
