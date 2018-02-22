class AddDiscussionReadersCount < ActiveRecord::Migration[4.2]
  def change
    add_column :discussions, :seen_by_count, :integer, null: false, default: 0
    add_index :discussion_readers, :last_read_at
  end
end
