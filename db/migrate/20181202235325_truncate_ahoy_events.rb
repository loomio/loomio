class TruncateAhoyEvents < ActiveRecord::Migration[5.1]
  def change
    execute("TRUNCATE ahoy_events")
    remove_index :ahoy_events, name: :index_ahoy_events_on_time
  end
end
