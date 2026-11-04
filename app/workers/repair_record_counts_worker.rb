class RepairRecordCountsWorker < ApplicationJob
  queue_as :record_count_repair

  class DeferredRecordsError < StandardError; end

  # A full pass may take hours with throttling. Its dedicated worker keeps
  # ordinary queues available, and the service commits before every pause.
  # Deferred owners make the job fail visibly after all tables are checked;
  # operators can rerun those tables without rewriting already correct rows.
  def perform(**options)
    report_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    results = RecordCountRepairService.run(**options) do |table, stats|
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if stats[:finished] || now - report_at >= 5
        Rails.logger.info("Record count repair #{job_id} #{table}: #{stats.to_json}")
        report_at = now
      end
    end
    Rails.logger.info("Record count repair #{job_id} results: #{results.to_json}")
    deferred_tables = results.filter_map { |table, stats| table if stats[:deferred].positive? }
    if deferred_tables.any?
      raise DeferredRecordsError, "Record count repair deferred records in #{deferred_tables.join(',')}. Rerun these tables from the beginning; use smaller batches or a longer timeout if needed."
    end
    results
  end
end
