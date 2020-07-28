class AddDiscardedAtNullIndexToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_index :discussions, :discarded_at, name: :discussions_discarded_at_null, where: 'discarded_at IS NULL'
  end
end
