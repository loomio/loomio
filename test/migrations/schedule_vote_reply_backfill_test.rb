require 'test_helper'
require_relative '../../db/migrate/20261113000000_schedule_vote_reply_backfill'

class ScheduleVoteReplyBackfillTest < ActiveSupport::TestCase
  setup { freeze_time }
  test 'upgrading schedules repair after the ten minute deployment window without changing threads' do
    before = TopicItem.order(:id).pluck(:id, :parent_id, :depth, :position_key)
    assert_enqueued_with(job: BackfillVoteRepliesWorker, queue: 'low', at: 10.minutes.from_now) do
      ScheduleVoteReplyBackfill.new.migrate(:up)
    end
    assert_equal before, TopicItem.order(:id).pluck(:id, :parent_id, :depth, :position_key)
  end
end
