class RemoveAhoy < ActiveRecord::Migration[6.1]
  def change
    drop_table :ahoy_visits
    drop_table :ahoy_messages
    drop_table :ahoy_events
  end
end
