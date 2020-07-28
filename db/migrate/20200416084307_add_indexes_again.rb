class AddIndexesAgain < ActiveRecord::Migration[5.2]
  def change
    add_index :discussion_readers, :last_read_at, name: :index_discussion_readers_last_read_at_not_null, where: "last_read_at IS NOT NULL"
    add_index :discussion_readers, :discussion_id, name: :index_discussion_readers_discussion_id
  end
end
