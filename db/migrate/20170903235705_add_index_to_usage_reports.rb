class AddIndexToUsageReports < ActiveRecord::Migration[4.2]
  def change
    add_index :usage_reports, :canonical_host
  end
end
