class EnqueueLegacyAnonymousVoteMigrations < ActiveRecord::Migration[8.0]
  def up
    LegacyAnonymousVoteMigrationService
      .eligible_poll_scope
      .find_each(order: :asc) do |poll|
        LegacyAnonymousVoteMigrationCleanupService.remove_invalid_stances!(poll: poll)
      end

    queue_adapter = MigrateLegacyAnonymousVotesWorker.queue_adapter
    if queue_adapter.is_a?(ActiveJob::QueueAdapters::InlineAdapter)
      MigrateLegacyAnonymousVotesWorker.queue_adapter = :solid_queue
    end

    Poll.where(
      anonymous: true,
      voting_system: Poll.voting_systems.fetch("stance")
    ).distinct.pluck(:topic_id).each do |topic_id|
      MigrateLegacyAnonymousVotesWorker
        .set(wait: 15.minutes)
        .perform_later(topic_id)
    end
  ensure
    MigrateLegacyAnonymousVotesWorker.queue_adapter = queue_adapter if queue_adapter
  end

  def down
    # The conversion is intentionally one-way and the scheduled jobs are safe
    # to leave in the queue if the migration is rolled back.
  end
end
