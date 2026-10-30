class IndexEventPollSchedules < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :polls, :event_starts_at, where: "poll_type = 'event'", algorithm: :concurrently
    add_index :polls, :source_outcome_id, algorithm: :concurrently
    add_index :polls, :calendar_uid, unique: true, algorithm: :concurrently
  end
end
