class AddEventLevelToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :event_level, :integer, :default => 1, :null => false
  end
end
