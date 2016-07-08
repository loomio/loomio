class AddAnalyticsEnabled < ActiveRecord::Migration
  def change
    add_column :groups, :analytics_enabled, :boolean, default: false, null: false
  end
end
