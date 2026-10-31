require 'test_helper'
require_relative '../../db/migrate/20261031000002_add_polls_one_at_a_time'

class AddPollsOneAtATimeTest < ActiveSupport::TestCase
  test 'schema changes preserve legacy choices and delay conversion for ten minutes' do
    records = [topics(:discussion_topic), discussion_templates(:cleanup_discussion_template)]
    records.each { |record| record.update_columns(allow_concurrent_polls: false) }
    migration = AddPollsOneAtATime.new
    migration.down

    travel_to Time.utc(2026, 10, 31, 12) do
      assert_enqueued_with(job: BackfillPollSequenceWorker, queue: 'low', at: 10.minutes.from_now) do
        migration.up
      end
    end
    [Topic, DiscussionTemplate].each(&:reset_column_information)

    records.each do |record|
      assert_nil record.reload[:polls_one_at_a_time]
      assert_equal true, record.polls_one_at_a_time
      assert_equal false, record.class.new[:polls_one_at_a_time]
    end
  ensure
    [Topic, DiscussionTemplate].each(&:reset_column_information)
  end
end
