class CreateNotificationConsolidationStates < ActiveRecord::Migration[8.1]
  def change
    # A durable cursor lets the preparation release warm the copy while the old
    # application is live, then resume and catch up after its writers drain.
    create_table :notification_consolidation_states, id: false do |t|
      t.string :name, null: false, primary_key: true
      t.bigint :notification_id_cursor, null: false, default: 0
      t.bigint :notification_id_high_water, null: false, default: 0
      t.datetime :completed_at
      t.timestamps
    end
  end
end
