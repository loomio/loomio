class AddVersionToUsageReports < ActiveRecord::Migration[4.2]
  def change
    add_column :usage_reports, :version, :string
  end
end
