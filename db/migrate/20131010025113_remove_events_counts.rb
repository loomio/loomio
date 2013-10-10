class RemoveEventsCounts < ActiveRecord::Migration
  def up
    remove_column :discussions, :events_count
    remove_column :discussion_readers, :read_events_count
  end

  def down
    add_column :discussion_readers, :read_events_count, :integer, default: 0, null: false
    add_column :discussions, :events_count, :integer, default: 0, null: false
  end
end
