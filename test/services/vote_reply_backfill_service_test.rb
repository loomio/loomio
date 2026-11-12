require 'test_helper'

class VoteReplyBackfillServiceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'repairs group and direct replies and descendants without changing votes or read positions' do
    [:discussion_topic, :direct_topic].each do |fixture|
      topic, stance, reply, nested = misplaced_reply(fixture: fixture)
      stance_before = stance.attributes
      sequences = topic.items.order(:id).pluck(:id, :sequence_id)
      reader = TopicReader.for(user: users(:guest_normal), topic: topic)
      reader.viewed!(reply.created_topic_item.sequence_id)
      read_ranges = reader.reload.read_ranges_string

      assert_no_difference ['Notification.count', 'NotificationDelivery.count', 'TopicItem.count', 'Stance.count'] do
        assert_equal 1, VoteReplyBackfillService.new.run_batch[:repaired]
      end
      assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
      # The reply is at the depth limit; its child becomes its timeline sibling.
      assert_equal stance.created_topic_item.id, nested.created_topic_item.reload.parent_id
      assert_equal stance_before, stance.reload.attributes
      assert_equal sequences, topic.items.order(:id).pluck(:id, :sequence_id)
      assert_equal read_ranges, reader.reload.read_ranges_string
      TopicService.verify_integrity!(topic.id)
      repaired_tree = tree(topic)
      assert_equal 0, VoteReplyBackfillService.new.run_batch[:repaired]
      assert_equal repaired_tree, tree(topic)
    end
  end

  test 'respects capped nesting and leaves correct late reason and ordinary vote replies alone' do
    topic, stance, reply = misplaced_reply(max_depth: 2)
    assert_equal 1, VoteReplyBackfillService.new.run_batch[:repaired]
    assert_equal stance.created_topic_item.parent_id, reply.created_topic_item.reload.parent_id
    correct_tree = tree(topic)
    assert_equal 0, VoteReplyBackfillService.new.run_batch[:repaired]
    assert_equal correct_tree, tree(topic)

    ordinary = stance.poll.stances.latest.find_by!(participant: users(:guest_loud))
    ordinary.choice = 'Agree'
    ordinary.reason = 'Reason provided with vote'
    StanceService.create(stance: ordinary, actor: users(:guest_loud))
    ordinary_reply = CommentService.create(comment: Comment.new(parent: ordinary, body: 'Ordinary reply'), actor: users(:guest_normal))
    correct_tree = tree(topic)
    assert_equal 0, VoteReplyBackfillService.new.run_batch[:repaired]
    assert_equal correct_tree, tree(topic)
    assert_equal ordinary.created_topic_item.parent_id, ordinary_reply.created_topic_item.parent_id
  end

  test 'scans bounded newest first batches and resumes without chasing new records' do
    topic, stance, reply = misplaced_reply
    newest = TopicItem.maximum(:id)
    first = VoteReplyBackfillService.new(batch_size: 1).run_batch
    assert_equal newest, first[:before_id]
    assert_equal 1, first[:checked]
    assert_not first[:finished]
    later = CommentService.create(comment: Comment.new(parent: stance, body: 'Created after scan began'), actor: users(:guest_loud))
    result = first
    checked = first[:checked]
    until result[:finished]
      following = VoteReplyBackfillService.new(before_id: result[:before_id], batch_size: 2).run_batch
      assert_operator following[:before_id], :<, result[:before_id] if following[:checked].positive?
      checked += following[:checked]
      result = following
    end
    assert_equal TopicItem.where('id <= ?', newest).count, checked
    assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
    assert_equal stance.created_topic_item.id, later.created_topic_item.reload.parent_id
    TopicService.verify_integrity!(topic.id)
  end

  test 'a failed repair rolls back its topic and a retry completes it' do
    topic, stance, reply = misplaced_reply
    before = tree(topic)
    timeout_before = ActiveRecord::Base.connection.select_value('SHOW statement_timeout')
    TopicService.stub(:reset_child_positions, ->(*) { raise 'interrupted repair' }) do
      assert_raises(RuntimeError) { VoteReplyBackfillService.new.run_batch }
    end
    assert_equal before, tree(topic)
    assert_equal timeout_before, ActiveRecord::Base.connection.select_value('SHOW statement_timeout')
    assert_equal 1, VoteReplyBackfillService.new.run_batch[:repaired]
    assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
    TopicService.verify_integrity!(topic.id)
  end

  test 'a busy topic defers without advancing past the failed batch' do
    topic, stance, reply = misplaced_reply
    locked, release = Queue.new, Queue.new
    holder = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Topic.where(id: topic.id).with_write_lock(:id) do
          locked << true
          release.pop
        end
      end
    end
    locked.pop
    before = tree(topic)
    assert_raises(ActiveRecord::LockWaitTimeout) { VoteReplyBackfillService.new.run_batch }
    assert_equal before, tree(topic)
    release << true
    holder.value
    assert_equal 1, VoteReplyBackfillService.new.run_batch[:repaired]
    assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
  ensure
    release << true if release && holder&.alive?
    holder&.join
  end

  test 'a timed out repair restores the tree and connection timeouts before retrying' do
    topic, stance, reply = misplaced_reply
    connection = ActiveRecord::Base.connection
    before = tree(topic)
    settings = %w[statement_timeout lock_timeout].map { |name| connection.select_value("SHOW #{name}") }
    TopicService.stub(:reset_child_positions, ->(*) { connection.execute('SELECT pg_sleep(0.1)') }) do
      assert_raises(ActiveRecord::QueryCanceled) do
        VoteReplyBackfillService.new(statement_timeout_ms: 50).run_batch
      end
    end
    assert_equal before, tree(topic)
    assert_equal settings, %w[statement_timeout lock_timeout].map { |name| connection.select_value("SHOW #{name}") }
    assert_equal 1, VoteReplyBackfillService.new.run_batch[:repaired]
    assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
  end

  test 'an interrupted batch retains completed topics and retries the remainder' do
    cases = [:discussion_topic, :direct_topic].map { |fixture| misplaced_reply(fixture: fixture) }.sort_by { |row| row.first.id }
    completed, pending = cases
    repair = TopicService.method(:repair)
    TopicService.stub(:repair, ->(id) { raise 'interrupted batch' if id == pending.first.id; repair.call(id) }) do
      assert_raises(RuntimeError) { VoteReplyBackfillService.new.run_batch }
    end
    assert_equal completed[1].created_topic_item.id, completed[2].created_topic_item.reload.parent_id
    refute_equal pending[1].created_topic_item.id, pending[2].created_topic_item.reload.parent_id
    assert_equal 1, VoteReplyBackfillService.new.run_batch[:repaired]
    cases.each do |topic, stance, reply|
      assert_equal stance.created_topic_item.id, reply.created_topic_item.reload.parent_id
      TopicService.verify_integrity!(topic.id)
    end
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

    # Reproduce the old lookup while writing the historical occurrence. All
    # positions and counters then reflect the actual pre-fix tree, not a mock.
    stance.define_singleton_method(:created_topic_item) { nil }
    reply = CommentService.create(comment: Comment.new(parent: stance, body: 'Misplaced reply'), actor: users(:guest_loud))
    stance.singleton_class.remove_method(:created_topic_item)
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Nested reply'), actor: users(:guest_loud))
    [topic, stance.reload, reply, nested]
  end

  def tree(topic)
    topic.items.order(:id).pluck(:id, :parent_id, :depth, :position, :position_key, :child_count)
  end
end
