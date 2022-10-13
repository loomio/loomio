class DropUsageReports < ActiveRecord::Migration[6.1]
  def change
    drop_table :usage_reports
  end
end
