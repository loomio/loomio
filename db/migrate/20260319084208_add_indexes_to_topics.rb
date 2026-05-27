class AddIndexesToTopics < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :topics, :last_activity_at, order: :desc, algorithm: :concurrently, if_not_exists: true
    add_index :topics, :locked_at, algorithm: :concurrently, if_not_exists: true
  end
end
