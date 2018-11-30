class RemoveUnusedIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :discussion_readers, name: :index_discussion_readers_on_participating
    remove_index :discussion_readers, name: :index_discussion_readers_on_volume
    remove_index :discussion_readers, name: :index_discussion_readers_on_last_read_at
  end
end
