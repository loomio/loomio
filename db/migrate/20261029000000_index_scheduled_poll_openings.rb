class IndexScheduledPollOpenings < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :polls, :opening_at,
      where: 'opened_at IS NULL AND closed_at IS NULL AND discarded_at IS NULL AND opening_at IS NOT NULL',
      name: 'index_polls_on_pending_opening_at', algorithm: :concurrently
  end
end
