class AddEventableIdIndexToEvents < ActiveRecord::Migration
  def up
    add_index :events, :eventable_id
  end

  def down
    remove_index :events, :column => :eventable_id
  end
end
