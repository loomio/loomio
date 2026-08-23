require "test_helper"

class CommentReplyNotificationTest < ActiveSupport::TestCase
  inline_jobs

  setup do
    @parent_author = users(:user)
    @reply_author = users(:alien)
    @discussion = discussions(:discussion)
    @discussion.add_guest!(@reply_author, @parent_author)
    @parent = Comment.new(parent: @discussion, body: "Parent", author: @parent_author)
    CommentService.create(comment: @parent, actor: @parent_author)
    ActionMailer::Base.deliveries.clear
  end

  test "an explicit reply mention creates direct deliveries without an topic_item" do
    comment = Comment.new(
      body: "Replying to @#{@parent_author.username}",
      body_format: "md",
      parent: @parent
    )

    assert_no_difference -> { TopicItem.where(kind: "comment_replied_to").count } do
      CommentService.create(comment: comment, actor: @reply_author)
    end

    notification = Notification.find_by!(
      kind: "comment_replied_to",
      subject: comment
    )
    assert_equal comment, notification.subject
    assert_equal [ @parent_author.id ], notification.recipient_user_ids
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_includes ActionMailer::Base.deliveries.last.to, @parent_author.email
  end

  test "replaying the source topic_item does not repeat reply delivery" do
    comment = Comment.new(
      body: "Replying to @#{@parent_author.username}",
      body_format: "md",
      parent: @parent
    )
    topic_item = CommentService.create(comment: comment, actor: @reply_author)

    assert_no_difference [ "Notification.count", "NotificationDelivery.count", "ActionMailer::Base.deliveries.count" ] do
      PublishTopicItemWorker.perform_now(topic_item.id)
    end
  end

  test "a comment author does not notify themselves" do
    comment = Comment.new(
      body: "Self mention @#{@parent_author.username}",
      body_format: "md",
      parent: @parent
    )

    assert_no_difference -> { Notification.where(kind: "comment_replied_to").count } do
      CommentService.create(comment: comment, actor: @parent_author)
    end
  end
end
