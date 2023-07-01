class RemoveFeaturesFromGroups < ActiveRecord::Migration[7.0]
  def change
    remove_column :groups, :features, :jsonb, default: {}, null: false
    remove_column :groups, :analytics_enabled, :boolean, default: false, null: false
  end
end
