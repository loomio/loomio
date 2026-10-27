require 'test_helper'
require_relative '../../db/migrate/20261027000000_schedule_item_tag_backfill'

class ScheduleItemTagBackfillTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'upgrading while a backfill is active preserves its continuation without scheduling another pass' do
    job = BackfillItemTagsWorker.new(phase: 'search', after_id: 100, through_id: 200)
    queued = SolidQueue::Job.enqueue(job)

    assert_no_enqueued_jobs(only: BackfillItemTagsWorker) do
      ScheduleItemTagBackfill.new.migrate(:up)
    end
    assert SolidQueue::ReadyExecution.exists?(job_id: queued.id)
    assert_equal job.job_id, queued.reload.active_job_id
  end

  test 'an already-migrated installation backfills automatically after the ten-minute upgrade window' do
    topic = topics(:discussion_topic)
    discussion = topic.topicable
    discussion.created_topic_item.update_columns(tags: ['Opening'])
    discussion.update_pg_search_document
    document = PgSearch::Document.find_by!(searchable: discussion)
    document.update_columns(tags: ['Inherited'])
    topic.update_columns(tags: ['Stale'])

    travel_to Time.utc(2026, 10, 27, 12) do
      assert_enqueued_with(job: BackfillItemTagsWorker, queue: 'low', at: 10.minutes.from_now) do
        ScheduleItemTagBackfill.new.migrate(:up)
      end
      perform_enqueued_jobs(only: BackfillItemTagsWorker, at: 9.minutes.from_now)
      assert_equal ['Stale'], topic.reload.tags
      assert_equal ['Inherited'], document.reload.tags

      travel 10.minutes
      perform_enqueued_jobs(only: BackfillItemTagsWorker, at: Time.current)
      assert_equal ['Opening'], topic.reload.tags
      assert_equal ['Inherited'], document.reload.tags

      travel 1.second
      perform_enqueued_jobs(only: BackfillItemTagsWorker, at: Time.current)
      assert_equal ['Opening'], document.reload.tags
      assert_no_enqueued_jobs(only: BackfillItemTagsWorker)
    end
  end
end
