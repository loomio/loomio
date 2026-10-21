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

  test "an explicit reply mention uses the source new_comment topic item" do
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
      subject: comment.created_topic_item
    )
    assert_equal comment.created_topic_item, notification.subject
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
    topic_item = nil
    CommentService.create(comment: comment, actor: @reply_author) { |created_topic_item| topic_item = created_topic_item }

    assert_no_difference [ "Notification.count", "NotificationDelivery.count" ] do
      PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    end
  end

  %w[md html].each do |format|
    %i[discussion own_comment].each do |parent_type|
      test "a #{format} self mention on #{parent_type} delivers a mention email" do
        body = if format == "md"
          "Self mention @#{@parent_author.username}"
        else
          %(<p>Self mention <span data-mention-id="#{@parent_author.username}">@#{@parent_author.username}</span></p>)
        end
        comment = Comment.new(
          body: body,
          body_format: format,
          parent: parent_type == :discussion ? @discussion : @parent
        )

        CommentService.create(comment: comment, actor: @parent_author)

        notification = Notification.about(comment).find_by!(kind: "user_mentioned")
        assert_equal [@parent_author.id], notification.recipient_user_ids
        assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
        delivery = notification.notification_deliveries.find_by!(channel: "email")
        assert_predicate delivery, :delivered_at?
        assert_equal [@parent_author.email], ActionMailer::Base.deliveries.last.to
        assert_not Notification.about(comment).exists?(kind: "comment_replied_to")
      end
    end
  end

  test "replying to your own comment without a mention does not notify yourself" do
    comment = Comment.new(
      body: "Another thought",
      body_format: "md",
      parent: @parent
    )

    assert_no_difference -> { Notification.where(kind: %w[user_mentioned comment_replied_to]).count } do
      CommentService.create(comment: comment, actor: @parent_author)
    end
  end
end
