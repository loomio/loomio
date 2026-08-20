class MigrateLegacyAnonymousVotesWorker < ApplicationJob
  queue_as :low

  limits_concurrency to: 1,
                     key: ->(topic_id) { topic_id },
                     duration: 1.hour

  def perform(topic_id)
    failures = []

    LegacyAnonymousVoteMigrationService
      .eligible_poll_scope
      .where(topic_id: topic_id)
      .find_each do |poll|
        LegacyAnonymousVoteMigrationService.migrate!(poll: poll)
      rescue LegacyAnonymousVoteMigrationService::MigrationError => error
        failures << "Poll #{poll.id}: #{error.message}"
      end

    return if failures.empty?

    raise LegacyAnonymousVoteMigrationService::MigrationError, failures.join("; ")
  end
end
