class AddNotificationConsolidationRepairState < ActiveRecord::Migration[8.1]
  def change
    return unless table_exists?(:notification_consolidation_states)

    add_column :notification_consolidation_states, :repair_completed_at, :datetime
  end
end
