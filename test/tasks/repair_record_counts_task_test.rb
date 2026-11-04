require 'test_helper'
require 'rake'

class RepairRecordCountsTaskTest < ActiveSupport::TestCase
  OPTIONS = %w[TABLES BATCH_SIZE PAUSE_SECONDS STATEMENT_TIMEOUT_MS AFTER_ID LIMIT DRY_RUN].freeze

  setup do
    @environment_before = OPTIONS.index_with { |key| ENV[key] }
    OPTIONS.each { |key| ENV.delete(key) }
    Rake::Task.define_task(:environment) unless Rake::Task.task_defined?(:environment)
    unless Rake::Task.task_defined?('loomio:repair_record_counts')
      load Rails.root.join('lib/tasks/record_counts.rake')
    end
    @task = Rake::Task['loomio:repair_record_counts']
    @task.reenable
  end

  teardown do
    @environment_before.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    @task.reenable
  end

  test 'the command enqueues the throttled repair and returns without running the service' do
    options = { tables: RecordCountRepairService::COLUMNS.keys, batch_size: 100, pause_seconds: 0.1,
                statement_timeout_ms: 1000, after_id: 0, limit: nil, dry_run: false }
    RecordCountRepairService.stub(:run, ->(**) { flunk 'The command must enqueue rather than run the repair' }) do
      assert_enqueued_with(job: RepairRecordCountsWorker, queue: 'record_count_repair', args: [options]) do
        output, = capture_io { @task.invoke }
        assert_match(/Queued record count repair job .+ on record_count_repair/, output)
      end
    end
  end

  test 'the command captures audit scope and resume settings in the queued job' do
    ENV['TABLES'] = 'users'
    ENV['AFTER_ID'] = '100'
    ENV['LIMIT'] = '200'
    ENV['BATCH_SIZE'] = '25'
    ENV['PAUSE_SECONDS'] = '0.2'
    ENV['STATEMENT_TIMEOUT_MS'] = '500'
    ENV['DRY_RUN'] = 'false'
    options = { tables: ['users'], batch_size: 25, pause_seconds: 0.2,
                statement_timeout_ms: 500, after_id: 100, limit: 200, dry_run: true }

    assert_enqueued_with(job: RepairRecordCountsWorker, queue: 'record_count_repair', args: [options]) do
      output, = capture_io { @task.invoke }
      assert_match(/Queued record count audit job/, output)
    end
  end

  test 'invalid scope is rejected before enqueueing a job' do
    ENV['TABLES'] = 'memberships'
    assert_no_enqueued_jobs(only: RepairRecordCountsWorker) do
      assert_raises(ArgumentError) { @task.invoke }
    end
  end
end
