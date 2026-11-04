require 'test_helper'

class SearchIndexTransactionTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @topic = topics(:discussion_topic)
    @user = users(:member_normal)
  end

  test 'moving discussion and standalone poll topics queues the correct index scope after commit' do
    poll = PollService.create(params: { group_id: @topic.group_id, title: 'Moving poll', poll_type: 'proposal',
      closing_at: 2.days.from_now, poll_option_names: [ 'Agree' ] }, actor: users(:admin))
    [ @topic.topicable, poll ].each do |record|
      record.update_pg_search_document
      clear_enqueued_jobs
      Topic.transaction do
        TopicService.move(topic: record.topic, params: { group_id: groups(:subgroup).id }, actor: users(:admin))
        assert_no_enqueued_jobs(only: [ ReindexDiscussionWorker, ReindexPollWorker ])
      end
      job = record.is_a?(Poll) ? ReindexPollWorker : ReindexDiscussionWorker
      assert_enqueued_with(job: job, args: [ record.id ])
      perform_enqueued_jobs(only: job)
      assert_equal groups(:subgroup).id, PgSearch::Document.where(searchable: record).sole.group_id
    end
  end
end
