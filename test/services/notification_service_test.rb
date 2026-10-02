require 'test_helper'

class NotificationServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @discussion = discussions(:discussion)
    @topic_item = topic_items(:discussion_created_topic_item)
  end

  test "mark_as_read marks matching unviewed notifications as viewed" do
    notification, delivery = create_notification_delivery(user: @user, subject: @discussion)

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert_predicate delivery.reload, :viewed?
  end

  test "mark_as_read finds direct and topic item notifications through indexed subject branches" do
    _direct_notification, direct_delivery = create_notification_delivery(user: @user, subject: @discussion)
    _topic_item_notification, topic_item_delivery = create_notification_delivery(user: @user, subject: @topic_item)

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert_predicate direct_delivery.reload, :viewed?
    assert_predicate topic_item_delivery.reload, :viewed?
    assert_includes Notification.about(@discussion).to_sql, "UNION"
  end

  test "mark_as_read does not touch notifications for a different itemable" do
    other_discussion = discussions(:public_discussion)
    _notification, delivery = create_notification_delivery(user: @user, subject: other_discussion)

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert_not_predicate delivery.reload, :viewed?
  end

  test "mark_as_read does not touch notifications for a different user" do
    other_user = users(:alien)

    _notification, delivery = create_notification_delivery(user: other_user, subject: @discussion)

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert_not_predicate delivery.reload, :viewed?
  end

  test "mark_as_read does not touch already-viewed notifications" do
    _notification, delivery = create_notification_delivery(
      user: @user,
      subject: @discussion,
      viewed_at: Time.current
    )

    updated_at_before = delivery.reload.updated_at

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert_equal updated_at_before, delivery.reload.updated_at
  end

  test "viewed marks all unviewed notifications as viewed" do
    _notification, delivery = create_notification_delivery(user: @user, subject: @discussion)

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.viewed(user: @user)
    end

    assert_predicate delivery.reload, :viewed?
  end

  test "reading a previously read comment clears its reactions only for the reader's in-app delivery" do
    comment = comments(:public_discussion_comment)
    item = topic_items(:public_discussion_comment_topic_item)
    reader = TopicReader.for(user: @user, topic: comment.topic)
    reader.viewed!([[0, item.sequence_id]])
    reaction = Reaction.create!(reactable: comment, user: @admin, reaction: "🙂")
    notification, delivery = create_notification_delivery(user: @user, subject: reaction)
    other_user_delivery = NotificationDelivery.create!(
      notification: notification, recipient: @admin, channel: "in_app", delivered_at: Time.current
    )
    email_delivery = NotificationDelivery.create!(
      notification: notification, recipient: @user, channel: "email", delivered_at: Time.current
    )
    _other_notification, other_item_delivery = create_notification_delivery(user: @user, subject: @topic_item)
    root_reaction = Reaction.create!(reactable: comment.topic.topicable, user: @admin, reaction: "🙂")
    _root_notification, root_delivery = create_notification_delivery(user: @user, subject: root_reaction)
    publications = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { publications << [models, options] }) do
      TopicService.mark_as_read(topic: comment.topic, params: {ranges: item.sequence_id}, actor: @user)
    end

    assert_predicate delivery.reload, :viewed?
    assert_not_predicate other_user_delivery.reload, :viewed?
    assert_not_predicate email_delivery.reload, :viewed?
    assert_not_predicate other_item_delivery.reload, :viewed?
    assert_not_predicate root_delivery.reload, :viewed?
    assert_equal [[0, item.sequence_id]], reader.reload.read_ranges
    assert publications.any? { |models, options| models == [notification] && options == {user_id: @user.id} }
  end

  private

  def create_notification_delivery(user:, subject:, viewed_at: nil)
    notification = Notification.create!(
      actor: @admin,
      kind: "discussion_edited",
      subject: subject
    )
    delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: user,
      channel: "in_app",
      delivered_at: Time.current,
      viewed_at: viewed_at
    )
    [ notification, delivery ]
  end
end
