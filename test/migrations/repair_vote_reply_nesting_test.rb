require 'test_helper'
require_relative '../../db/migrate/20261113000000_schedule_vote_reply_backfill'
require_relative '../../db/migrate/20261113000001_repair_vote_reply_nesting'

class RepairVoteReplyNestingTest < ActiveSupport::TestCase
  setup { freeze_time }

  test 'enqueues only affected group and direct topics without changing the tree during migration' do
    cases = [:discussion_topic, :direct_topic].map { |fixture| misplaced_reply(fixture: fixture) }
    before = cases.to_h { |topic, *| [topic.id, tree(topic)] }
    assert_enqueued_jobs 2, only: RepairTopicWorker do
      assert_equal cases.map { |topic, *| topic.id }.reverse, RepairVoteReplyNesting.new.up
    end
    cases.each do |topic, *|
      assert_equal before.fetch(topic.id), tree(topic)
      assert_enqueued_with(job: RepairTopicWorker, args: [topic.id], queue: 'low', at: 10.minutes.from_now)
    end
  end

  test 'deduplicates multiple affected replies in the same topic' do
    topic, stance = misplaced_reply
    make_misplaced_reply(stance)
    assert_enqueued_jobs 1, only: RepairTopicWorker do
      assert_equal [topic.id], RepairVoteReplyNesting.new.up
    end
  end

  test 'existing repair jobs restore nesting counts and read positions without changing votes or notifications' do
    cases = [:discussion_topic, :direct_topic].map { |fixture| misplaced_reply(fixture: fixture) }
    snapshots = cases.map do |topic, stance, reply, _|
      reader = TopicReader.for(user: users(:guest_normal), topic: topic)
      reader.viewed!(reply.created_topic_item.sequence_id)
      [stance.attributes, topic.items.order(:id).pluck(:id, :sequence_id), reader, reader.reload.read_ranges_string]
    end
    RepairVoteReplyNesting.new.up
    assert_no_difference ['Notification.count', 'NotificationDelivery.count', 'TopicItem.count', 'Stance.count'] do
      perform_enqueued_jobs(only: RepairTopicWorker)
    end
    cases.zip(snapshots).each do |(topic, stance, reply, nested), (vote_before, sequences, reader, read_ranges)|
      assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
      assert_equal stance.created_topic_item.id, nested.created_topic_item.reload.parent_id
      assert_equal vote_before, stance.reload.attributes
      assert_equal sequences, topic.items.order(:id).pluck(:id, :sequence_id)
      assert_equal read_ranges, reader.reload.read_ranges_string
      TopicService.verify_integrity!(topic.id)
    end
    assert_no_enqueued_jobs(only: RepairTopicWorker) { assert_empty RepairVoteReplyNesting.new.up }
  end

  test 'respects the nesting cap and skips correct replies' do
    topic, stance, reply = misplaced_reply(max_depth: 2)
    RepairVoteReplyNesting.new.up
    perform_enqueued_jobs(only: RepairTopicWorker)
    assert_equal stance.created_topic_item.parent_id, reply.created_topic_item.reload.parent_id
    correct_tree = tree(topic)
    assert_no_enqueued_jobs(only: RepairTopicWorker) { assert_empty RepairVoteReplyNesting.new.up }
    assert_equal correct_tree, tree(topic)
  end

  test 'ordinary vote replies and unrelated timeline items do not enqueue repairs' do
    topic = topics(:discussion_topic)
    TopicService.repair(topic.id)
    20.times do |i|
      CommentService.create(comment: Comment.new(parent: topic.topicable, body: "Unrelated #{i}"), actor: users(:guest_loud))
    end
    poll = PollService.create(params: {topic_id: topic.id, title: 'Ordinary vote', poll_type: 'proposal',
      poll_option_names: %w[Agree Disagree], closing_at: 3.days.from_now}, actor: topic.topicable.author)
    voter = users(:guest_normal)
    stance = poll.stances.latest.find_by!(participant: voter)
    stance.choice = 'Agree'
    stance.reason = 'Initial reason'
    StanceService.create(stance: stance, actor: voter)
    CommentService.create(comment: Comment.new(parent: stance, body: 'Ordinary reply'), actor: users(:guest_loud))
    assert_no_enqueued_jobs(only: RepairTopicWorker) { assert_empty RepairVoteReplyNesting.new.up }
  end

  test 'the superseded migration does not enqueue the removed backfill worker on fresh installs' do
    assert_no_enqueued_jobs { ScheduleVoteReplyBackfill.new.up }
  end

  private

  def misplaced_reply(fixture: :discussion_topic, max_depth: 3)
    topic = topics(fixture)
    topic.update!(max_depth: max_depth)
    topic.topicable.create_missing_created_topic_item! unless topic.topicable.created_topic_item
    poll = PollService.create(params: {topic_id: topic.id, title: 'Late reason', poll_type: 'proposal',
      poll_option_names: %w[Agree Disagree], closing_at: 3.days.from_now}, actor: topic.topicable.author)
    voter = users(:guest_normal)
    stance = poll.stances.latest.find_by!(participant: voter)
    stance.choice = 'Agree'
    StanceService.create(stance: stance, actor: voter)
    StanceService.update(stance: stance, actor: voter, params: {choice: 'Agree', reason: 'Added later', reason_format: 'md'})
    reply = make_misplaced_reply(stance)
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Nested reply'), actor: users(:guest_loud))
    [topic, stance.reload, reply, nested]
  end

  def make_misplaced_reply(stance)
    stance.define_singleton_method(:created_topic_item) { nil }
    CommentService.create(comment: Comment.new(parent: stance, body: 'Misplaced reply'), actor: users(:guest_loud))
  ensure
    stance.singleton_class.remove_method(:created_topic_item)
  end

  def tree(topic)
    topic.items.order(:id).pluck(:id, :parent_id, :depth, :position, :position_key, :child_count)
  end
end
