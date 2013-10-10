class AddItemCounts < ActiveRecord::Migration
  def up
    add_column :discussions, :items_count, :integer,  default: 0, null: false
    add_column :discussion_readers, :read_items_count, :integer, default: 0, null: false
    add_index :events, :created_at
    add_index :events, [:eventable_type, :eventable_id]
    remove_index :events, :eventable_id
    remove_index :events, :user_id
  end

  def down
    add_index :events, :user_id
    add_index :events, :eventable_id
    remove_index :events, :column => [:eventable_type, :eventable_id]
    remove_index :events, :column => :created_at
    remove_column :discussion_readers, :read_items_count
    remove_column :discussions, :items_count
  end
end
