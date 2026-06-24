class AddReportCreatedAtIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :discussions, :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :comments,    :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :stances,     :created_at, algorithm: :concurrently, if_not_exists: true
    add_index :outcomes,    :created_at, algorithm: :concurrently, if_not_exists: true
  end
end
