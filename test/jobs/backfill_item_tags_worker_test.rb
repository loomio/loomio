require 'test_helper'

class BackfillItemTagsWorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'continuations persist the cursor before advancing to the search phase and then stop' do
    ids = Topic.order(:id).limit(2).ids
    options = {phase: 'summaries', after_id: 0, through_id: ids.last, batch_size: 1, statement_timeout_ms: 1000}
    following = options.merge(after_id: ids.first)
    assert_enqueued_with(job: BackfillItemTagsWorker, queue: 'low', args: [following]) do
      first = BackfillItemTagsWorker.perform_now(**options)
      assert_equal ids.first, first[:after_id]
    end
    clear_enqueued_jobs

    search = options.merge(phase: 'search', after_id: 0, through_id: nil)
    assert_enqueued_with(job: BackfillItemTagsWorker, queue: 'low', args: [search]) do
      BackfillItemTagsWorker.perform_now(**following)
    end
    clear_enqueued_jobs
    assert_no_enqueued_jobs(only: BackfillItemTagsWorker) do
      assert BackfillItemTagsWorker.perform_now(**search)[:finished]
    end
  end
end
