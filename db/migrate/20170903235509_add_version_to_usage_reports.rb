class AddVersionToUsageReports < ActiveRecord::Migration
  def change
    add_column :usage_reports, :version, :string
  end
end
