namespace :loomio do
  desc 'Backfill contribution tag summaries and search tags after upgrading web and workers'
  task backfill_item_tags: :environment do
    options = {
      phase: ENV.fetch('PHASE', 'summaries'),
      after_id: Integer(ENV.fetch('AFTER_ID', '0')),
      through_id: ENV.key?('THROUGH_ID') ? Integer(ENV.fetch('THROUGH_ID')) : nil,
      batch_size: Integer(ENV.fetch('BATCH_SIZE', '500')),
      statement_timeout_ms: Integer(ENV.fetch('STATEMENT_TIMEOUT_MS', '1000'))
    }
    ItemTagBackfillService.new(**options)
    job = BackfillItemTagsWorker.perform_later(**options)
    puts "Queued item tag backfill job #{job.job_id} on #{job.queue_name}"
  end
end
