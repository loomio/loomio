require 'test_helper'

class Events::NewCommentTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "NC User #{SecureRandom.hex(4)}", email: "ncuser_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group = Group.create!(name: "NC Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    @group.add_admin!(@user)
    @discussion = create_discussion(group: @group, author: @user)
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

  test "returns an event" do
    comment = Comment.new(parent: @discussion, body: "Yet another", author: @user)
    result = Events::NewComment.publish!(comment)
    assert_kind_of Events::NewComment, result
  end
end
