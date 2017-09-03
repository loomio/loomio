class AddIndexToUsageReports < ActiveRecord::Migration
  def change
    add_index :usage_reports, :canonical_host
  end
end
