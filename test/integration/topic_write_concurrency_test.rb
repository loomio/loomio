require 'test_helper'

class TopicWriteConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @poll_ids = []
    @actor = users(:admin)
    @group = Group.create!(name: 'Concurrent topic writes', group_privacy: 'secret')
    @group.add_admin!(@actor)
  end

  teardown do
    # Anonymous voters have no fixture file; remove them through their polls
    # before fixture loading can leave references to recycled user/poll IDs.
    Poll.where(id: @poll_ids).destroy_all
  end

  test 'poll closing waits for thread discard without holding the poll lock' do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: 'Closing and discard' }, actor: @actor)
    poll = create_poll(topic_id: discussion.topic_id)

    while_writer_waits_on_topics([discussion.topic_id], -> { PollService.do_closing_work(poll: Poll.find(poll.id)) }) do
      TopicService.discard(topic: discussion.topic, actor: @actor)
    end

    assert poll.reload.closed_at
    assert poll.discarded?
    assert discussion.topic.reload.discarded_at
    assert_equal 0, discussion.topic.active_polls_count
  end

  test 'anonymous direct poll closing and thread discard follow the same lock order' do
    discussion = DiscussionService.create(params: { title: 'Direct anonymous close' }, actor: @actor)
    poll = create_poll(topic_id: discussion.topic_id, anonymous: true)

    while_writer_waits_on_topics([discussion.topic_id], -> { PollService.do_closing_work(poll: Poll.find(poll.id)) }) do
      TopicService.discard(topic: discussion.topic, actor: @actor)
    end

    assert poll.reload.closed_at
    assert poll.discarded?
    assert_equal 0, discussion.topic.reload.active_polls_count
    assert discussion.topic.has_anonymous_polls?
  end

  test 'thread destruction completes while a closer waits without repeated item lock queries' do
    poll = create_poll(group_id: @group.id)
    topic_id = poll.topic_id
    3.times { CommentService.create(comment: Comment.new(parent: poll, body: 'Deleted with topic'), actor: @actor) }
    writer = lambda do
      ActiveRecord::Base.cache { PollService.do_closing_work(poll: Poll.find(poll.id)) }
    rescue ActiveRecord::RecordNotFound => error
      error
    end
    item_topic_locks = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      item_topic_locks << payload[:sql] if payload[:sql].match?(/SELECT "topics"\."id" FROM "topics".*FOR NO KEY UPDATE/)
    end

    result = while_writer_waits_on_topics([topic_id], writer) { Topic.find(topic_id).destroy! }

    assert_instance_of ActiveRecord::RecordNotFound, result
    assert_not Topic.exists?(topic_id)
    assert_not Poll.exists?(poll.id)
    assert_not TopicItem.exists?(topic_id: topic_id)
    # One from the competing operation's setup, one from Topic's destruction lock.
    # Individual item destruction reuses the topic's existing protection.
    assert_equal 2, item_topic_locks.length
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test 'closing follows a poll moved while waiting for its topic lock' do
    poll = create_poll(group_id: @group.id, hide_results: :until_closed)
    source_id = poll.topic_id
    destination = DiscussionService.create(params: { title: 'Moved closing poll' }, actor: @actor)
    poll_item_id = poll.created_topic_item.id

    MessageChannelService.stub(:publish_models, nil) do
      while_writer_waits_on_topics([source_id, destination.topic_id], -> { PollService.do_closing_work(poll: Poll.find(poll.id)) }) do
        MoveCommentsWorker.new.perform([poll_item_id], source_id, destination.topic_id, @actor.id)
      end
    end

    assert_equal destination.topic_id, poll.reload.topic_id
    assert poll.closed_at
    assert_equal 0, @group.reload.polls_count
    assert_equal 0, Topic.find(source_id).active_polls_count
    assert_equal 0, destination.topic.reload.active_polls_count
    assert_equal destination.topic_id, poll.created_topic_item.topic_id
    TopicService.verify_integrity!(destination.topic_id)
  end

  test 'a vote waiting for thread discard rechecks access before writing' do
    poll = create_poll(group_id: @group.id)
    stance = poll.stances.latest.find_by!(participant_id: @actor.id)
    stance.choice = poll.poll_option_names.first
    stance.reason = 'Waiting vote'
    writer = lambda do
      StanceService.create(stance: stance, actor: @actor)
    rescue CanCan::AccessDenied => error
      error
    end

    result = while_writer_waits_on_topics([poll.topic_id], writer) do
      TopicService.discard(topic: poll.topic, actor: @actor)
    end

    assert_instance_of CanCan::AccessDenied, result
    assert_nil stance.reload.cast_at
    assert_not TopicItem.exists?(itemable: stance, kind: 'stance_created')
    assert_equal 0, poll.topic.reload.active_polls_count
  end

  test 'a replacement vote follows its poll when it moves while waiting' do
    poll = create_poll(group_id: @group.id, hide_results: :off)
    stance = poll.stances.latest.find_by!(participant_id: @actor.id)
    stance.choice = poll.poll_option_names.first
    stance.reason = 'First vote'
    StanceService.create(stance: stance, actor: @actor)
    stance.update_column(:updated_at, 20.minutes.ago)
    destination = DiscussionService.create(params: { title: 'Moved replacement vote' }, actor: @actor)
    replacement = nil
    writer = lambda do
      replacement = StanceService.update(stance: Stance.find(stance.id), actor: User.find(@actor.id),
        params: { stance_choices_attributes: [{ poll_option_id: poll.poll_options.last.id }], reason: 'Changed vote' })
    end

    MessageChannelService.stub(:publish_models, nil) do
      while_writer_waits_on_topics([poll.topic_id, destination.topic_id], writer) do
        MoveCommentsWorker.new.perform([poll.created_topic_item.id], poll.topic_id, destination.topic_id, @actor.id)
      end
    end

    assert_not_equal stance.id, replacement.id
    assert_not stance.reload.latest?
    assert replacement.reload.latest?
    assert_equal destination.topic_id, replacement.created_topic_item.topic_id
    assert_equal destination.topic_id, poll.reload.topic_id
    TopicService.verify_integrity!(destination.topic_id)
  end

  test 'a vote waiting for poll closing cannot write or publish a hidden reason' do
    poll = create_poll(group_id: @group.id, hide_results: :until_closed)
    stance = poll.stances.latest.find_by!(participant_id: @actor.id)
    stance.choice = poll.poll_option_names.first
    stance.reason = 'Vote racing with close'
    writer = lambda do
      StanceService.create(stance: stance, actor: @actor)
    rescue CanCan::AccessDenied => error
      error
    end

    result = while_writer_waits_on_topics([poll.topic_id], writer) { PollService.close(poll: poll, actor: @actor) }

    assert_instance_of CanCan::AccessDenied, result
    assert_nil stance.reload.cast_at
    assert_not TopicItem.exists?(itemable: stance, kind: 'stance_created')
    assert_equal 0, poll.topic.reload.active_polls_count
  end

  test 'an edit waiting for closing rechecks cached poll state before writing' do
    poll = create_poll(group_id: @group.id)
    writer = lambda do
      ActiveRecord::Base.cache do
        PollService.update(poll: Poll.find(poll.id), actor: User.find(@actor.id), params: { title: 'Late edit' })
      end
    rescue CanCan::AccessDenied => error
      error
    end

    result = while_writer_waits_on_topics([poll.topic_id], writer) { PollService.close(poll: poll, actor: @actor) }

    assert_instance_of CanCan::AccessDenied, result
    assert_equal 'Concurrent poll', poll.reload.title
    assert poll.closed_at
  end

  test 'membership recount cannot overwrite a concurrent increment' do
    snapshot_ready = Queue.new
    release_recount = Queue.new
    reader_pid = Queue.new
    writer_pid = Queue.new
    group_id = @group.id
    user_id = users(:alien).id
    recount_group = Group.find(group_id)
    recount_group.define_singleton_method(:memberships) do
      super().tap do |relation|
        relation.define_singleton_method(:pick) do |*columns|
          super(*columns).tap do
            snapshot_ready << true
            Timeout.timeout(10) { release_recount.pop }
          end
        end
      end
    end
    reader = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        reader_pid << connection.raw_connection.backend_pid
        recount_group.update_membership_counts
      end
    end
    Timeout.timeout(10) { snapshot_ready.pop }
    writer = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        writer_pid << connection.raw_connection.backend_pid
        Membership.create!(group_id: group_id, user_id: user_id)
      end
    end
    wait_for_blocked_writer(Timeout.timeout(10) { writer_pid.pop }, Timeout.timeout(10) { reader_pid.pop }, writer)
    release_recount << true
    Timeout.timeout(10) { [reader, writer].each(&:value) }

    assert_equal [2, 1, 1], @group.reload.attributes.values_at('memberships_count', 'pending_memberships_count', 'admin_memberships_count')
    assert_equal @group.memberships.count, @group.memberships_count
  ensure
    release_recount << true
    [reader, writer].compact.each do |thread|
      thread.kill if thread.alive?
      thread.join
    end
  end

  test 'membership recount discards reads cached before a concurrent writer' do
    user = users(:alien)
    writer = nil
    ActiveRecord::Base.cache do
      count_before = user.memberships.count
      writer = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          Membership.create!(group_id: @group.id, user_id: user.id)
        end
      end
      Timeout.timeout(10) { writer.value }

      user.update_memberships_count

      assert_equal count_before + 1, user.reload.memberships_count
    end
  ensure
    if writer&.alive?
      writer.kill
      writer.join
    end
  end

  test 'reply creation waits for repair and leaves the tree and counts consistent' do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: 'Concurrent repair' }, actor: @actor)
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: 'Parent'), actor: @actor)
    writer = -> { CommentService.create(comment: Comment.new(parent: Comment.find(parent.id), body: 'Reply'), actor: User.find(@actor.id)) }

    while_writer_waits_on_topics([discussion.topic_id], writer) { TopicService.repair(discussion.topic_id) }

    item = parent.created_topic_item
    assert_equal 1, item.child_count
    assert_equal item.child_count, item.children.count
    TopicService.verify_integrity!(discussion.topic_id)
  end

  test 'parent deletion excludes reply insertion without extra parent lock queries' do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: 'Concurrent deletion' }, actor: @actor)
    discussion.topic.update!(max_depth: 10)
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: 'Parent'), actor: @actor)
    reply = CommentService.create(comment: Comment.new(parent: parent, body: 'Promoted reply'), actor: @actor)
    parent_item = parent.created_topic_item
    writer = -> { TopicItems::NewComment.create!(itemable: Comment.create!(parent: discussion, author: @actor, body: 'Sibling')) }
    locks = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      locks << payload[:sql] if payload[:sql].match?(/SELECT.*FROM "topic_items".*FOR UPDATE/i)
    end

    while_writer_waits_on_topics([discussion.topic_id], writer) { parent_item.destroy! }

    assert_empty locks
    assert_equal discussion.created_topic_item.id, reply.created_topic_item.reload.parent_id
    assert_equal 2, discussion.created_topic_item.reload.child_count
    TopicService.verify_integrity!(discussion.topic_id)
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  private

  def create_poll(**params)
    PollService.create(params: {
      title: 'Concurrent poll', poll_type: 'proposal', closing_at: 1.day.from_now,
      poll_option_names: %w[agree disagree]
    }.merge(params), actor: @actor).tap { |poll| @poll_ids << poll.id }
  end

  # Wait for PostgreSQL to confirm the writer is blocked, rather than assuming
  # an elapsed delay means it reached the topic lock. A short lock timeout on
  # the competing operation makes an inverted lock order fail deterministically.
  def while_writer_waits_on_topics(topic_ids, operation)
    pid = Queue.new
    writer = nil
    Topic.where(id: topic_ids).order(:id).with_write_lock(:id) do
      connection = ActiveRecord::Base.connection
      blocker_pid = connection.raw_connection.backend_pid
      writer = Thread.new do
        Thread.current.report_on_exception = false
        ActiveRecord::Base.connection_pool.with_connection do |writer_connection|
          pid << writer_connection.raw_connection.backend_pid
          operation.call
        end
      end
      writer_pid = Timeout.timeout(10) { pid.pop }
      wait_for_blocked_writer(writer_pid, blocker_pid, writer)
      connection.execute("SET LOCAL lock_timeout = '1s'")
      yield
    end
    Timeout.timeout(10) { writer.value }
  ensure
    if writer&.alive?
      writer.kill
      writer.join
    end
  end

  def wait_for_blocked_writer(writer_pid, blocker_pid, writer)
    Timeout.timeout(10) do
      until ActiveRecord::Base.connection.select_value("SELECT #{blocker_pid} = ANY(pg_blocking_pids(#{writer_pid}))")
        unless writer.alive?
          writer.value
          flunk 'Writer finished before waiting for the competing lock'
        end
        sleep 0.01
      end
    end
  end
end
