class EnqueueLegacyAnonymousVoteMigrations < ActiveRecord::Migration[8.0]
  def up
    # The 3.2 conversion classes no longer exist in 3.3. Empty databases can
    # continue, but installations with poll data must complete this migration
    # while running 3.2 rather than attempting a direct upgrade.
    return unless select_value("SELECT EXISTS (SELECT 1 FROM polls LIMIT 1)")

    raise ActiveRecord::MigrationError,
          "Existing installations must upgrade to Loomio 3.2 and complete the anonymous-poll conversion before upgrading to 3.3"
  end

  def down
    # The conversion is intentionally one-way and the scheduled jobs are safe
    # to leave in the queue if the migration is rolled back.
  end
end
