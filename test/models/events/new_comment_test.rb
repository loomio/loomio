require 'test_helper'

class Events::NewCommentTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @discussion = discussions(:discussion)
    @comment = Comment.new(parent: @discussion, body: "First", author: @user)
    CommentService.create(comment: @comment, actor: @user)
    @reply = Comment.new(body: "Reply", parent: @comment, author: @user)
    CommentService.create(comment: @reply, actor: @user)
  end

  test "creates an event" do
    comment = Comment.new(parent: @discussion, body: "Another", author: @user)
    assert_difference -> { Event.where(kind: 'new_comment').count }, 1 do
      Events::NewComment.publish!(comment)
    end
  end

  test "associates parent event if comment is reply" do
    parent_event = Events::NewComment.where(eventable: @comment).last
    child_event = Events::NewComment.where(eventable: @reply).last
    assert_equal parent_event.id, child_event.parent_id
  end

  test "does not attach a timeline comment to a topicless stance event" do
    poll = PollService.create(params: {
      poll_type: "poll",
      title: "Topicless stance event",
      poll_option_names: %w[Yes No],
      closing_at: 1.day.from_now,
      group_id: groups(:group).id,
      notify_on_open: false
    }, actor: @user)
    stance = poll.stances.find_by!(participant: @user)
    Event.create!(kind: "stance_created", eventable: stance, user: @user)
    comment = Comment.create!(parent: stance, user: @user, body: "Stance comment")

    event = Events::NewComment.publish!(comment)

    assert_equal poll.created_event.id, event.parent_id
  end

  test "returns an event" do
    comment = Comment.new(parent: @discussion, body: "Yet another", author: @user)
    result = Events::NewComment.publish!(comment)
    assert_kind_of Events::NewComment, result
  end
end
