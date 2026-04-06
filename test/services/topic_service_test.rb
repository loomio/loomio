require 'test_helper'

class TopicServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)

    @discussion = DiscussionService.create(params: {
      title: "Test Discussion",
      group_id: @group.id,
      max_depth: 2
    }, actor: @user)
    @topic = @discussion.topic

    @comment1 = Comment.new(body: "comment1", parent: @discussion)
    @comment2 = Comment.new(body: "comment2", parent: @comment1)
    @comment3 = Comment.new(body: "comment3", parent: @comment2)

    @discussion_event = @discussion.created_event
    @comment1_event = CommentService.create(comment: @comment1, actor: @user)
    @comment2_event = CommentService.create(comment: @comment2, actor: @user)
    @comment3_event = CommentService.create(comment: @comment3, actor: @user)

    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now,
      group_id: @group.id,
      topic_id: @topic.id
    }, actor: @user)
    @poll_created_event = poll.created_event
  end

  test "flattens events to max_depth 1" do
    @topic.update!(max_depth: 1)
    TopicService.repair_thread(@topic.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_event].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 1, @comment2_event.depth
    assert_equal 1, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @discussion_event.id, @comment2_event.parent_id
    assert_equal @discussion_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_event.parent_id
  end

  test "branches events at max_depth 2" do
    @topic.update!(max_depth: 2)
    TopicService.repair_thread(@topic.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_event].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 2, @comment2_event.depth
    assert_equal 2, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @comment1_event.id, @comment2_event.parent_id
    assert_equal @comment1_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_event.parent_id
  end

  test "branches events at max_depth 3" do
    @topic.update!(max_depth: 3)
    TopicService.repair_thread(@topic.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_event].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 2, @comment2_event.depth
    assert_equal 3, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @comment1_event.id, @comment2_event.parent_id
    assert_equal @comment2_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_event.parent_id
  end

  # -- Move --

  test "move moves discussion to a public_only group" do
    admin = users(:admin)
    public_group = groups(:public_group)
    public_group.add_member!(admin)

    discussion = discussions(:discussion)
    TopicService.move(topic: discussion.topic, params: { group_id: public_group.id }, actor: admin)
    assert_equal false, discussion.topic.reload.private
  end

  test "move updates privacy for private_only groups" do
    admin = users(:admin)
    public_group = groups(:public_group)
    public_group.add_admin!(admin)
    subgroup = groups(:subgroup)

    discussion = DiscussionService.create(params: { title: "Test", group_id: public_group.id, private: false }, actor: admin)
    assert_equal false, discussion.topic.private
    TopicService.move(topic: discussion.topic, params: { group_id: subgroup.id }, actor: admin)
    assert_equal true, discussion.topic.reload.private
  end

  test "move updates topic group" do
    admin = users(:admin)
    alien_group = groups(:alien_group)
    alien_group.add_member!(admin)

    discussion = discussions(:discussion)
    TopicService.move(topic: discussion.topic, params: { group_id: alien_group.id }, actor: admin)
    assert_equal alien_group.id, discussion.topic.reload.group_id
  end

  # -- Close / Reopen --

  test "closes a topic" do
    discussion = DiscussionService.create(params: {
      title: 'Closeable Discussion',
      group_id: @group.id
    }, actor: @user)

    assert_nil discussion.topic.closed_at
    TopicService.close(topic: discussion.topic, actor: @user)
    assert_not_nil discussion.topic.reload.closed_at
  end

  test "reopens a closed topic" do
    discussion = DiscussionService.create(params: {
      title: 'Reopenable Discussion',
      group_id: @group.id
    }, actor: @user)
    discussion.topic.update!(closed_at: 1.day.ago)

    TopicService.reopen(topic: discussion.topic, actor: @user)
    assert_nil discussion.topic.reload.closed_at
  end
end
