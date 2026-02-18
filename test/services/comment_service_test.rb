require 'test_helper'

class CommentServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)
  end

  test "creates a comment and returns an event" do
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "My body is ready",
      body_format: "md"
    )

    event = CommentService.create(comment: comment, actor: @user)

    assert_kind_of Event, event
    assert comment.persisted?
    assert_equal "My body is ready", comment.body
  end

  test "returns false when creating invalid comment" do
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "",  # Empty body is invalid
      body_format: "md"
    )

    result = CommentService.create(comment: comment, actor: @user)

    assert_equal false, result
    assert_not comment.persisted?
  end

  test "creates user_mentioned event when mentioning a user" do
    @another_user.update(username: 'testuser')
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "A mention for @testuser!",
      body_format: "md"
    )

    assert_difference "Event.where(kind: 'user_mentioned').count", 1 do
      CommentService.create(comment: comment, actor: @user)
    end

    assert_includes comment.mentioned_users, @another_user
  end

  test "marks notification as read on reply" do
    # Create a comment that mentions the user
    @another_user.update(username: 'replytest')
    @user.update(username: 'originaluser')

    mention_comment = Comment.new(
      author: @another_user,
      discussion: @discussion,
      body: "hi @originaluser",
      body_format: "md"
    )
    CommentService.create(comment: mention_comment, actor: @another_user)

    notifications = Notification.joins(:event).where('events.kind': 'user_mentioned', viewed: false, user_id: @user)
    assert_equal 1, notifications.count

    # Reply to the comment
    reply_comment = Comment.new(
      parent: mention_comment,
      author: @user,
      discussion: @discussion,
      body: "gidday",
      body_format: "md"
    )
    CommentService.create(comment: reply_comment, actor: @user)

    # Notification should be marked as read
    assert_equal 0, notifications.count
  end

  test "updates a comment" do
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "Original body",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    CommentService.update(comment: comment, params: { body: "Updated body" }, actor: @user)

    assert_equal "Updated body", comment.reload.body
  end

  test "does not renotify old mentions on update" do
    @another_user.update(username: 'mentiontest')

    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "Original",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    # First mention should create notification
    assert_difference "@another_user.notifications.count", 1 do
      CommentService.update(comment: comment, params: { body: "A mention for @mentiontest!" }, actor: @user)
    end

    # Second update with same mention should not create new notification
    assert_no_difference "@another_user.notifications.count" do
      CommentService.update(comment: comment, params: { body: "Hello again @mentiontest" }, actor: @user)
    end
  end

  test "does not update an invalid comment" do
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "Original body",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    CommentService.update(comment: comment, params: { body: "" }, actor: @user)

    assert_equal "Original body", comment.reload.body
  end

  test "destroys a comment when authorized" do
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "To be deleted",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    assert_difference "Comment.count", -1 do
      CommentService.destroy(comment: comment, actor: @user)
    end
  end

  test "does not destroy comment when unauthorized" do
    comment = Comment.new(
      discussion: @discussion,
      author: @user,
      body: "Protected comment",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    unauthorized_user = User.create!(
      name: 'Unauthorized',
      email: 'unauthorized@example.com',
      email_verified: true,
      username: 'unauthorized'
    )

    assert_raises CanCan::AccessDenied do
      CommentService.destroy(comment: comment, actor: unauthorized_user)
    end
  end
end
