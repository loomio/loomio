class AddDiscussionReadersCount < ActiveRecord::Migration
  def change
    add_column :discussions, :seen_by_count, :integer, null: false, default: 0
    add_index :discussion_readers, :last_read_at
  end
end
