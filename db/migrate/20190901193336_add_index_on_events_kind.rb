class AddIndexOnEventsKind < ActiveRecord::Migration[5.2]
  def change
    add_index :events, :kind
  end
end
