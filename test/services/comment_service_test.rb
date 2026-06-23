require 'test_helper'

class CommentServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "creates a comment and returns an event" do
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "My body is ready",
      body_format: "md"
    )

    event = CommentService.create(comment: comment, actor: @user)

    assert_kind_of Event, event
    assert comment.persisted?
    assert_equal "My body is ready", comment.body
  end

  test "marks created comment as read for the author" do
    reader = TopicReader.for(user: @user, topic: @discussion.topic)
    reader.viewed!(@discussion.topic.ranges)

    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "Read my own comment",
      body_format: "md"
    )

    event = CommentService.create(comment: comment, actor: @user)

    assert reader.reload.has_read?(event.sequence_id)
    assert_equal 0, reader.unread_items_count
  end

  test "raises when creating invalid comment" do
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "",
      body_format: "md"
    )

    assert_raises ActiveRecord::RecordInvalid do
      CommentService.create(comment: comment, actor: @user)
    end
    assert_not comment.persisted?
  end

  test "raises when comment exceeds topic comment length limit" do
    @discussion.topic.update!(comment_length_max: 10)
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "This comment is too long",
      body_format: "md"
    )

    assert_raises ActiveRecord::RecordInvalid do
      CommentService.create(comment: comment, actor: @user)
    end
    assert_not comment.persisted?
    assert_includes comment.errors[:body], "Comment must be 10 characters or less"
  end

  test "comment length limit counts like javascript string length" do
    @discussion.topic.update!(comment_length_max: 1)
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "😄",
      body_format: "md"
    )

    assert_raises ActiveRecord::RecordInvalid do
      CommentService.create(comment: comment, actor: @user)
    end
    assert_includes comment.errors[:body], "Comment must be 1 characters or less"
  end

  test "comment length limit ignores html tags" do
    @discussion.topic.update!(comment_length_max: 10)
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "<p><strong>12345</strong></p>",
      body_format: "html"
    )

    CommentService.create(comment: comment, actor: @user)

    assert comment.persisted?
    assert_equal 5, comment.body_visible_text_length
  end

  test "comment length limit counts visible text inside html tags" do
    @discussion.topic.update!(comment_length_max: 4)
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "<p><strong>12345</strong></p>",
      body_format: "html"
    )

    assert_raises ActiveRecord::RecordInvalid do
      CommentService.create(comment: comment, actor: @user)
    end
    assert_includes comment.errors[:body], "Comment must be 4 characters or less"
  end

  test "builds discussion topic with comment length limit" do
    discussion = DiscussionService.build(
      params: { title: "Limited comments", group_id: @group.id, comment_length_max: 120 },
      actor: @admin
    )

    assert_equal 120, discussion.topic.comment_length_max
  end

  test "builds standalone poll topic with comment length limit" do
    poll = PollService.build(
      params: {
        title: "Limited poll comments",
        poll_type: "poll",
        group_id: @group.id,
        poll_option_names: ["yes"],
        closing_at: 3.days.from_now,
        comment_length_max: 80
      },
      actor: @admin
    )

    assert_equal 80, poll.topic.comment_length_max
  end

  test "creates user_mentioned event when mentioning a user" do
    @admin.update!(username: "mentionme#{SecureRandom.hex(4)}")
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "A mention for @#{@admin.username}!",
      body_format: "md"
    )

    assert_difference "Event.where(kind: 'user_mentioned').count", 1 do
      CommentService.create(comment: comment, actor: @user)
    end

    assert_includes comment.mentioned_users, @admin
  end

  test "marks notification as read on reply" do
    @user.update!(username: "replyuser#{SecureRandom.hex(4)}")

    mention_comment = Comment.new(
      author: @admin,
      parent: @discussion,
      body: "hi @#{@user.username}",
      body_format: "md"
    )
    CommentService.create(comment: mention_comment, actor: @admin)

    notifications = Notification.joins(:event).where('events.kind': 'user_mentioned', viewed: false, user_id: @user)
    assert_equal 1, notifications.count

    reply_comment = Comment.new(
      parent: mention_comment,
      author: @user,
      body: "gidday",
      body_format: "md"
    )
    CommentService.create(comment: reply_comment, actor: @user)

    assert_equal 0, notifications.count
  end

  test "updates a comment" do
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "Original body",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    CommentService.update(comment: comment, params: { body: "Updated body" }, actor: @user)

    assert_equal "Updated body", comment.reload.body
  end

  test "does not renotify old mentions on update" do
    @admin.update!(username: "mentiontest#{SecureRandom.hex(4)}")

    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "Original",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    # First mention should create notification
    assert_difference "@admin.notifications.count", 1 do
      CommentService.update(comment: comment, params: { body: "A mention for @#{@admin.username}!" }, actor: @user)
    end

    # Second update with same mention should not create new notification
    assert_no_difference "@admin.notifications.count" do
      CommentService.update(comment: comment, params: { body: "Hello again @#{@admin.username}" }, actor: @user)
    end
  end

  test "does not update an invalid comment" do
    comment = Comment.new(
      parent: @discussion,
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
      parent: @discussion,
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
      parent: @discussion,
      author: @user,
      body: "Protected comment",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    unauthorized_user = User.create!(
      name: 'Unauthorized',
      email: "unauthorized#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "unauthorized#{SecureRandom.hex(4)}"
    )

    assert_raises CanCan::AccessDenied do
      CommentService.destroy(comment: comment, actor: unauthorized_user)
    end
  end
end
