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
      status: "delivered",
      delivered_at: Time.current,
      viewed_at: viewed_at
    )
    [ notification, delivery ]
  end

end
