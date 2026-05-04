require 'test_helper'

class MoveCommentsWorkerTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @group = groups(:group)

    @source = DiscussionService.create(params: { title: "Source #{SecureRandom.hex(4)}", group_id: @group.id }, actor: @admin)
    @target = DiscussionService.create(params: { title: "Target #{SecureRandom.hex(4)}", group_id: @group.id }, actor: @admin)
    ActionMailer::Base.deliveries.clear
  end

  test "moves a top-level comment to target thread" do
    comment = Comment.new(parent: @source, body: "move me", author: @user)
    event = CommentService.create(comment: comment, actor: @user)

    MoveCommentsWorker.new.perform([event.id], @source.topic_id, @target.topic_id)

    event.reload
    comment.reload
    assert_equal @target.topic_id, event.topic_id
    assert_equal @target.id, comment.parent_id
    assert_equal 'Discussion', comment.parent_type
  end

  test "moves a comment and its reply together" do
    c1 = Comment.new(parent: @source, body: "parent comment", author: @user)
    e1 = CommentService.create(comment: c1, actor: @user)

    c2 = Comment.new(parent: c1, body: "reply", author: @user)
    e2 = CommentService.create(comment: c2, actor: @user)

    MoveCommentsWorker.new.perform([e1.id], @source.topic_id, @target.topic_id)

    e1.reload; e2.reload; c1.reload; c2.reload
    # Both events moved
    assert_equal @target.topic_id, e1.topic_id
    assert_equal @target.topic_id, e2.topic_id
    # Parent comment reparented to target discussion
    assert_equal @target.id, c1.parent_id
    assert_equal 'Discussion', c1.parent_type
    # Reply keeps its parent (the moved comment)
    assert_equal c1.id, c2.parent_id
    assert_equal 'Comment', c2.parent_type
  end

  test "reparents reply whose parent comment was not moved" do
    c1 = Comment.new(parent: @source, body: "stays behind", author: @user)
    e1 = CommentService.create(comment: c1, actor: @user)

    c2 = Comment.new(parent: c1, body: "gets moved", author: @user)
    e2 = CommentService.create(comment: c2, actor: @user)

    # Only move the reply, not the parent
    MoveCommentsWorker.new.perform([e2.id], @source.topic_id, @target.topic_id)

    e1.reload; e2.reload; c1.reload; c2.reload
    # Parent stays in source
    assert_equal @source.topic_id, e1.topic_id
    # Reply moved and reparented to target discussion
    assert_equal @target.topic_id, e2.topic_id
    assert_equal @target.id, c2.parent_id
    assert_equal 'Discussion', c2.parent_type
  end

  test "reparents comment on a stance when moved" do
    poll = PollService.create(params: {
      title: "Poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['agree', 'disagree'],
      topic_id: @source.topic_id
    }, actor: @admin)

    stance = poll.stances.undecided.find_by(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    StanceService.create(stance: stance, actor: @user)

    comment = Comment.new(parent: stance, body: "comment on stance", author: @user)
    event = CommentService.create(comment: comment, actor: @user)

    MoveCommentsWorker.new.perform([event.id], @source.topic_id, @target.topic_id)

    event.reload; comment.reload
    assert_equal @target.topic_id, event.topic_id
    assert_equal @target.id, comment.parent_id
    assert_equal 'Discussion', comment.parent_type
  end

  test "moves poll events to target topic" do
    poll = PollService.create(params: {
      title: "Moveable poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['agree', 'disagree'],
      topic_id: @source.topic_id
    }, actor: @admin)

    poll_event = poll.created_event

    MoveCommentsWorker.new.perform([poll_event.id], @source.topic_id, @target.topic_id)

    poll.reload; poll_event.reload
    assert_equal @target.topic_id, poll.topic_id
    assert_equal @target.topic_id, poll_event.topic_id
  end

  test "does not move events from another topic" do
    other = DiscussionService.create(params: { title: "Other #{SecureRandom.hex(4)}", group_id: @group.id }, actor: @admin)
    comment = Comment.new(parent: other, body: "wrong thread", author: @user)
    event = CommentService.create(comment: comment, actor: @user)

    MoveCommentsWorker.new.perform([event.id], @source.topic_id, @target.topic_id)

    event.reload
    # Event stays where it was — not in source topic so it's filtered out
    assert_equal other.topic_id, event.topic_id
  end

  test "repairs both source and target threads" do
    comment = Comment.new(parent: @source, body: "move me", author: @user)
    event = CommentService.create(comment: comment, actor: @user)

    source_items_before = @source.topic.reload.items_count
    target_items_before = @target.topic.reload.items_count

    MoveCommentsWorker.new.perform([event.id], @source.topic_id, @target.topic_id)

    assert_operator @source.topic.reload.items_count, :<, source_items_before
    assert_operator @target.topic.reload.items_count, :>, target_items_before
  end
end
