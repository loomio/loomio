require 'test_helper'

class EventServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)

    @discussion = Discussion.new(
      title: "Test Discussion",
      group: @group,
      author: @user,
      max_depth: 2
    )

    @group.add_admin!(@user)
    @group.add_admin!(@discussion.author)

    DiscussionService.create(discussion: @discussion, actor: @discussion.author)

    @comment1 = Comment.create!(
      body: "comment1",
      discussion: @discussion,
      author: @user
    )

    @comment2 = Comment.create!(
      body: "comment2",
      parent: @comment1,
      discussion: @discussion,
      author: @user
    )

    @comment3 = Comment.create!(
      body: "comment3",
      parent: @comment2,
      discussion: @discussion,
      author: @user
    )

    @discussion_event = @discussion.created_event
    @comment1_event = CommentService.create(comment: @comment1, actor: @comment1.author)
    @comment2_event = CommentService.create(comment: @comment2, actor: @comment2.author)
    @comment3_event = CommentService.create(comment: @comment3, actor: @comment3.author)

    @poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: @poll, actor: @user)
    @poll_created_event = @poll.created_event

    @stance = Stance.find_by(participant: @user, poll: @poll)
    if @stance
      @stance.choice = "Agree"
      @stance.reason = "I agree"
      @stance_created_event = StanceService.create(stance: @stance, actor: @user)
    end
  end

  test "flattens events to max_depth 1" do
    @discussion.update(max_depth: 1)
    EventService.repair_discussion(@discussion.id)

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
    @discussion.update(max_depth: 2)
    EventService.repair_discussion(@discussion.id)

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
    @discussion.update(max_depth: 3)
    EventService.repair_discussion(@discussion.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_event].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 2, @comment2_event.depth
    assert_equal 3, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @comment1_event.id, @comment2_event.parent_id
    assert_equal @comment2_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_event.parent_id
  end
end
