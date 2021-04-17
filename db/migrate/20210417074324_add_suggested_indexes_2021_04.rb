class AddSuggestedIndexes202104 < ActiveRecord::Migration[6.0]
  def change
    commit_db_transaction
    add_index :events, [:eventable_id, :kind], algorithm: :concurrently
    add_index :polls, [:closed_at, :closing_at], algorithm: :concurrently
    add_index :polls, [:closed_at, :discussion_id], algorithm: :concurrently
  end
end
