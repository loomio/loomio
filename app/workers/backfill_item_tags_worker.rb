class BackfillItemTagsWorker < ApplicationJob
  queue_as :low
  retry_on ActiveRecord::QueryCanceled, ActiveRecord::LockWaitTimeout, ActiveRecord::Deadlocked,
    wait: 5.seconds, attempts: 20

  # Persist the cursor in each continuation job. Retrying an interrupted batch
  # is safe, and each one-second scheduling gap leaves ordinary workers free.
  def perform(phase: 'summaries', after_id: 0, through_id: nil, batch_size: 500, statement_timeout_ms: 1_000)
    options = { phase: phase, after_id: after_id, through_id: through_id,
      batch_size: batch_size, statement_timeout_ms: statement_timeout_ms }
    result = ItemTagBackfillService.new(**options).run_batch
    Rails.logger.info("Item tag backfill #{job_id}: #{result.to_json}")

    if result[:finished]
      return result if phase == 'search'

      options.merge!(phase: 'search', after_id: 0, through_id: nil)
    else
      options.merge!(after_id: result[:after_id], through_id: result[:through_id])
    end
    self.class.set(wait: 1.second).perform_later(**options)
    result
  end
end
