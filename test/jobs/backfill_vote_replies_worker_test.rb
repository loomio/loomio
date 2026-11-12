require 'test_helper'

class BackfillVoteRepliesWorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false
  setup { freeze_time }

  test 'continuations persist the descending cursor and stop after the final batch' do
    newest = TopicItem.maximum(:id)
    options = {before_id: nil, batch_size: 1, statement_timeout_ms: 5_000}
    following = options.merge(before_id: newest)
    assert_enqueued_with(job: BackfillVoteRepliesWorker, queue: 'low', args: [following], at: 1.second.from_now) do
      result = BackfillVoteRepliesWorker.perform_now(**options)
      assert_equal newest, result[:before_id]
    end
    clear_enqueued_jobs
    assert_no_enqueued_jobs(only: BackfillVoteRepliesWorker) do
      result = BackfillVoteRepliesWorker.perform_now(before_id: TopicItem.minimum(:id))
      assert result[:finished]
    end
  end

  test 'lock timeouts retry the same cursor without enqueuing a continuation' do
    options = {before_id: 100, batch_size: 5, statement_timeout_ms: 100}
    service = Object.new
    service.define_singleton_method(:run_batch) { raise ActiveRecord::LockWaitTimeout }
    VoteReplyBackfillService.stub(:new, service) do
      assert_enqueued_with(job: BackfillVoteRepliesWorker, args: [options], at: 5.seconds.from_now) do
        BackfillVoteRepliesWorker.perform_now(**options)
      end
    end
    assert_equal 1, enqueued_jobs.count { |job| job[:job] == BackfillVoteRepliesWorker }
  end
end
