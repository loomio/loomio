class EnqueueLegacyAnonymousVoteMigrations < ActiveRecord::Migration[8.0]
  def up
    # Loomio 3.2 shipped this migration with its asynchronous conversion code.
    # Direct 3.3 upgrades no longer load that runtime code; the later blocking
    # migration completes the same conversion synchronously.
  end

  def down
    # The conversion is intentionally one-way and the scheduled jobs are safe
    # to leave in the queue if the migration is rolled back.
  end
end
