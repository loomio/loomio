require 'test_helper'

class CommentServiceTest < ActiveSupport::TestCase
  inline_jobs "creates user_mentioned notification when mentioning a user",
              "marks notification as read on reply",
              "does not renotify old mentions on update"
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "creates a comment and returns an topic_item" do
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "My body is ready",
      body_format: "md"
    )

    topic_item = CommentService.create(comment: comment, actor: @user)

    assert_kind_of TopicItem, topic_item
    assert comment.persisted?
    assert_equal "My body is ready", comment.body
    assert_not Notification.about(comment).exists?(kind: "new_comment")
  end

  test "unmentioned comment does not create a notification record" do
    subscriber = @admin
    TopicReader.for(user: subscriber, topic: @discussion.topic).set_volume!(email: :loud, push: :mute)
    comment = Comment.new(
      parent: @discussion,
      body: "Subscriber delivery",
      body_format: "md"
    )

    topic_item = nil
    NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
      topic_item = CommentService.create(comment: comment, actor: @user)
    end

    assert_predicate comment, :persisted?
    assert_equal comment, topic_item.itemable
    assert_not Notification.about(comment).exists?
  end

  test "rolls back comment creation when topic_item creation fails" do
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "Do not leave this behind",
      body_format: "md"
    )

    error = assert_raises RuntimeError do
      TopicItems::NewComment.stub(:create!, ->(**) { raise "topic_item failed" }) do
        CommentService.create(comment: comment, actor: @user)
      end
    end

    assert_equal "topic_item failed", error.message
    assert_not Comment.exists?(body: "Do not leave this behind")
  end

  test "rolls back comment and topic_item when mention notification creation fails" do
    @admin.update!(username: "atomicmention#{SecureRandom.hex(4)}")
    comment = Comment.new(
      parent: @discussion,
      body: "Mention @#{@admin.username}",
      body_format: "md"
    )

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        CommentService.create(comment: comment, actor: @user)
      end
    end

    assert_not comment.persisted?
    assert_not TopicItem.exists?(itemable: comment)
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

    topic_item = CommentService.create(comment: comment, actor: @user)

    assert reader.reload.has_read?(topic_item.sequence_id)
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

  test "creates user_mentioned notification when mentioning a user" do
    @admin.update!(username: "mentionme#{SecureRandom.hex(4)}")
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "A mention for @#{@admin.username}!",
      body_format: "md"
    )

    assert_no_difference -> { TopicItem.where(kind: "user_mentioned").count } do
      CommentService.create(comment: comment, actor: @user)
    end

    assert_includes comment.mentioned_users, @admin
    notification = Notification.about(comment).find_by!(kind: "comment_replied_to")
    assert_equal [ @admin.id ], notification.recipient_user_ids
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
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

    notification = Notification.about(mention_comment).find_by!(kind: "user_mentioned")
    delivery = notification.notification_deliveries.find_by!(channel: "in_app", recipient: @user)
    assert_nil delivery.viewed_at

    reply_comment = Comment.new(
      parent: mention_comment,
      author: @user,
      body: "gidday",
      body_format: "md"
    )
    CommentService.create(comment: reply_comment, actor: @user)

    assert_not_nil delivery.reload.viewed_at
  end

  test "updates a comment" do
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "Original body",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    published_models = []
    assert_no_difference -> { TopicItem.where(kind: "comment_edited").count } do
      MessageChannelService.stub(:publish_topic_model, ->(model) { published_models << model }) do
        CommentService.update(comment: comment, params: { body: "Updated body" }, actor: @user)
      end
    end

    assert_equal "Updated body", comment.reload.body
    assert_equal [ comment ], published_models
  end

  test "rolls back an edited comment when mention notification creation fails" do
    @admin.update!(username: "rollbackmention#{SecureRandom.hex(4)}")
    comment = Comment.new(
      parent: @discussion,
      author: @user,
      body: "Original body",
      body_format: "md"
    )
    CommentService.create(comment: comment, actor: @user)

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        CommentService.update(
          comment: comment,
          params: { body: "Hello @#{@admin.username}" },
          actor: @user
        )
      end
    end

    assert_equal "Original body", comment.reload.body
    assert_not TopicItem.exists?(kind: "comment_edited", itemable: comment)
  end

  test "does not allow update to reparent a comment" do
    comment = Comment.new(parent: @discussion, author: @user, body: "Original body", body_format: "md")
    CommentService.create(comment: comment, actor: @user)
    other_discussion = DiscussionService.create(
      params: { title: "Other discussion", group_id: @group.id },
      actor: @user
    )

    refute CommentService.update(
      comment: comment,
      params: { parent_type: 'Discussion', parent_id: other_discussion.id },
      actor: @user
    )

    comment.reload
    assert_equal @discussion, comment.parent
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
    assert_difference -> { Notification.about(comment).where(kind: "comment_replied_to").count }, 1 do
      CommentService.update(comment: comment, params: { body: "A mention for @#{@admin.username}!" }, actor: @user)
    end

    # Second update with same mention should not create new notification
    assert_no_difference -> { Notification.about(comment).where(kind: "comment_replied_to").count } do
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

  test "destroying an topic_item reparents its timeline children" do
    comment = Comment.new(parent: @discussion, author: @user, body: "Parent")
    topic_item = CommentService.create(comment: comment, actor: @user)
    reply = Comment.new(parent: comment, author: @user, body: "Reply")
    reply_event = CommentService.create(comment: reply, actor: @user)

    topic_item.destroy!

    assert_equal topic_item.parent_id, reply_event.reload.parent_id
    assert_not CleanupService.events_missing_parent.exists?(id: reply_event.id)
  end

  test "destroying a topic root destroys its complete topic_item tree" do
    comment = Comment.new(parent: @discussion, author: @user, body: "Parent")
    topic_item = CommentService.create(comment: comment, actor: @user)
    reply = Comment.new(parent: comment, author: @user, body: "Reply")
    reply_event = CommentService.create(comment: reply, actor: @user)

    @discussion.created_topic_item.destroy!

    assert_not TopicItem.exists?(topic_item.id)
    assert_not TopicItem.exists?(reply_event.id)
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
