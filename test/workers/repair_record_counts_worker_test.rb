require 'test_helper'

class RepairRecordCountsWorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'the queued worker repairs its selected owners after argument serialization' do
    user = users(:user)
    group = groups(:group)
    user.update_column(:memberships_count, 999)
    group.update_column(:memberships_count, 999)

    perform_enqueued_jobs(only: RepairRecordCountsWorker) do
      RepairRecordCountsWorker.perform_later(tables: ['users'], batch_size: 2, pause_seconds: 0)
    end

    assert_equal user.memberships.count, user.reload.memberships_count
    assert_equal 999, group.reload.memberships_count
  end

  test 'a background audit reports drift without changing counters' do
    user = users(:user)
    user.update_column(:memberships_count, 999)

    results = RepairRecordCountsWorker.perform_now(tables: ['users'], pause_seconds: 0, dry_run: true)

    assert_equal 1, results.fetch('users')[:drifted]
    assert_equal 0, results.fetch('users')[:updated]
    assert_equal 999, user.reload.memberships_count
  end

  test 'deferred owners make the background job fail visibly after releasing its transaction' do
    user = users(:user)
    user.update_column(:memberships_count, 999)
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    writer = PG.connect(**config.slice(:host, :port, :password).merge(dbname: config[:database], user: config[:username]).compact)
    writer.exec('BEGIN')
    writer.exec("SELECT id FROM users WHERE id = #{user.id} FOR NO KEY UPDATE")

    error = assert_raises(RepairRecordCountsWorker::DeferredRecordsError) do
      RepairRecordCountsWorker.perform_now(tables: ['users'], pause_seconds: 0)
    end

    assert_includes error.message, 'users'
    assert_equal 999, user.reload.memberships_count
    assert_not ActiveRecord::Base.connection.transaction_open?
  ensure
    writer&.exec('ROLLBACK')
    writer&.close
  end
end
