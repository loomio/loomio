class DropRecentActivityCountFromGroups < ActiveRecord::Migration[7.2]
  def change
    remove_column :groups, :recent_activity_count, :integer, default: 0, null: false
  end
end
