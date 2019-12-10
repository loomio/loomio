class AddDiscardedAtToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :discarded_at, :datetime
    add_index :discussions, :discarded_at
  end
end
