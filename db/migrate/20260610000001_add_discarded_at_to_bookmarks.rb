class AddDiscardedAtToBookmarks < ActiveRecord::Migration[8.0]
  def change
    add_column :bookmarks, :discarded_at, :datetime
    add_index :bookmarks, :discarded_at
  end
end
