require 'test_helper'

class BackfillPollSequenceWorkerTest < ActiveSupport::TestCase
  test 'converts newest rows first, persists its cursor, and preserves edits before advancing to templates' do
    oldest, middle, newest = Topic.order(:id).limit(3).to_a
    [oldest, middle].each { |topic| topic.update_columns(allow_concurrent_polls: true, polls_one_at_a_time: nil) }
    newest.update_columns(allow_concurrent_polls: false, polls_one_at_a_time: nil)
    template = discussion_templates(:cleanup_discussion_template)
    template.update_columns(allow_concurrent_polls: false, polls_one_at_a_time: nil)

    following = {model_name: 'Topic', before_id: newest.id, batch_size: 1}
    assert_enqueued_with(job: BackfillPollSequenceWorker, queue: 'low', args: [following]) do
      assert_equal [newest.id], BackfillPollSequenceWorker.perform_now(batch_size: 1)
    end
    assert_equal true, newest.reload[:polls_one_at_a_time]
    assert_nil oldest.reload[:polls_one_at_a_time]
    assert_nil template.reload[:polls_one_at_a_time]
    clear_enqueued_jobs

    middle.update!(polls_one_at_a_time: true)
    assert_equal [oldest.id], BackfillPollSequenceWorker.perform_now(**following)
    assert_equal false, oldest.reload[:polls_one_at_a_time]
    assert_equal true, middle.reload[:polls_one_at_a_time]
    clear_enqueued_jobs

    assert_enqueued_with(job: BackfillPollSequenceWorker, queue: 'low', args: [{model_name: 'DiscussionTemplate', batch_size: 1}]) do
      assert_empty BackfillPollSequenceWorker.perform_now(model_name: 'Topic', before_id: oldest.id, batch_size: 1)
    end
    clear_enqueued_jobs

    assert_equal [template.id], BackfillPollSequenceWorker.perform_now(model_name: 'DiscussionTemplate', batch_size: 1)
    assert_equal true, template.reload[:polls_one_at_a_time]
    clear_enqueued_jobs
    assert_no_enqueued_jobs(only: BackfillPollSequenceWorker) do
      assert_empty BackfillPollSequenceWorker.perform_now(model_name: 'DiscussionTemplate', batch_size: 1)
    end
  end

  test 'retrying a completed batch does not undo a subsequent settings edit' do
    topic = topics(:discussion_topic)
    topic.update_columns(allow_concurrent_polls: false, polls_one_at_a_time: nil)
    BackfillPollSequenceWorker.perform_now
    topic.reload.update!(polls_one_at_a_time: false)

    assert_empty BackfillPollSequenceWorker.perform_now
    assert_equal false, topic.reload[:polls_one_at_a_time]
    assert_equal true, topic[:allow_concurrent_polls]
  end
end
