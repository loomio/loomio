class AddIndexesToTopics < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :topics, :last_activity_at, order: :desc, algorithm: :concurrently
    add_index :topics, :closed_at, algorithm: :concurrently
  end
end
