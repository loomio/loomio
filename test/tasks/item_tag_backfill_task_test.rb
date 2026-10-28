require 'test_helper'
require 'rake'

class ItemTagBackfillTaskTest < ActiveSupport::TestCase
  OPTIONS = %w[PHASE AFTER_ID THROUGH_ID BATCH_SIZE STATEMENT_TIMEOUT_MS].freeze

  setup do
    @environment_before = OPTIONS.index_with { |key| ENV[key] }
    OPTIONS.each { |key| ENV.delete(key) }
    Rake::Task.define_task(:environment) unless Rake::Task.task_defined?(:environment)
    load Rails.root.join('lib/tasks/item_tags.rake') unless Rake::Task.task_defined?('loomio:backfill_item_tags')
    @task = Rake::Task['loomio:backfill_item_tags']
    @task.reenable
  end

  teardown do
    @environment_before.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    @task.reenable
  end

  test 'the operator command queues validated resume settings without doing the backfill' do
    ENV['PHASE'] = 'search'
    ENV['AFTER_ID'] = '100'
    ENV['THROUGH_ID'] = '200'
    ENV['BATCH_SIZE'] = '25'
    options = {phase: 'search', after_id: 100, through_id: 200, batch_size: 25, statement_timeout_ms: 1000}
    assert_enqueued_with(job: BackfillItemTagsWorker, queue: 'low', args: [options]) do
      output, = capture_io { @task.invoke }
      assert_match(/Queued item tag backfill job .+ on low/, output)
    end
  end

  test 'invalid scope is rejected before a job is persisted' do
    ENV['PHASE'] = 'users'
    assert_no_enqueued_jobs(only: BackfillItemTagsWorker) do
      assert_raises(ArgumentError) { @task.invoke }
    end
  end
end
