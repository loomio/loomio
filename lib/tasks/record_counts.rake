namespace :loomio do
  desc 'Enqueue background repair of retained counts after deploying transactional count updates'
  task repair_record_counts: :environment do
    options = {
      tables: ENV.fetch('TABLES', RecordCountRepairService::COLUMNS.keys.join(',')).split(','),
      batch_size: Integer(ENV.fetch('BATCH_SIZE', '100')),
      pause_seconds: Float(ENV.fetch('PAUSE_SECONDS', '0.1')),
      statement_timeout_ms: Integer(ENV.fetch('STATEMENT_TIMEOUT_MS', '1000')),
      after_id: Integer(ENV.fetch('AFTER_ID', '0')),
      limit: ENV.key?('LIMIT') ? Integer(ENV.fetch('LIMIT')) : nil,
      dry_run: ENV.key?('DRY_RUN')
    }
    # Reject invalid options before persisting a job that cannot run.
    RecordCountRepairService.new(**options)
    job = RepairRecordCountsWorker.perform_later(**options)
    puts "Queued record count #{options[:dry_run] ? 'audit' : 'repair'} job #{job.job_id} on #{job.queue_name}"
  end
end
