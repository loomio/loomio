class AddIndexToEventsKind < ActiveRecord::Migration[5.1]
  def change
    add_index :events, :kind
  end
end
