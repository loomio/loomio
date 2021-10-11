class RemoveAhoy < ActiveRecord::Migration[6.1]
  def change
    drop_table(:ahoy_visits) if table_exists?(:ahoy_visits)
    drop_table :ahoy_messages if table_exists?(:ahoy_messages)
    drop_table :ahoy_events if table_exists?(:ahoy_events)
  end
end
