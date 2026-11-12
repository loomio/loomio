class BackfillVoteRepliesWorker < ApplicationJob
  queue_as :low
  retry_on ActiveRecord::QueryCanceled, ActiveRecord::LockWaitTimeout, ActiveRecord::Deadlocked,
    wait: 5.seconds, attempts: 20

  # Continuation arguments persist progress without holding a transaction or a
  # worker between batches. Replaying a batch after interruption is harmless.
  def perform(before_id: nil, batch_size: 500, statement_timeout_ms: 5_000)
    result = VoteReplyBackfillService.new(before_id: before_id, batch_size: batch_size,
      statement_timeout_ms: statement_timeout_ms).run_batch
    Rails.logger.info("Vote reply backfill #{job_id}: #{result.to_json}")
    unless result[:finished]
      self.class.set(wait: 1.second).perform_later(before_id: result[:before_id],
        batch_size: batch_size, statement_timeout_ms: statement_timeout_ms)
    end
    result
  end
end
