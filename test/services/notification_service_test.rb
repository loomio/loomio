require 'test_helper'

class NotificationServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @discussion = discussions(:discussion)
    @event = events(:discussion_created_event)
  end

  test "mark_as_read marks matching unviewed notifications as viewed" do
    notification = Notification.create!(
      user: @user,
      actor: @admin,
      event: @event,
      viewed: false
    )

    MessageChannelService.stub(:publish_models, ->(*) {}) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert notification.reload.viewed
  end

  test "mark_as_read does not touch notifications for a different eventable" do
    other_discussion = discussions(:public_discussion)
    other_event = events(:public_discussion_created_event)

    notification = Notification.create!(
      user: @user,
      actor: @admin,
      event: other_event,
      viewed: false
    )

    MessageChannelService.stub(:publish_models, ->(*) {}) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    refute notification.reload.viewed
  end

  test "mark_as_read does not touch notifications for a different user" do
    other_user = users(:alien)

    notification = Notification.create!(
      user: other_user,
      actor: @admin,
      event: @event,
      viewed: false
    )

    MessageChannelService.stub(:publish_models, ->(*) {}) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    refute notification.reload.viewed
  end

  test "mark_as_read does not touch already-viewed notifications" do
    notification = Notification.create!(
      user: @user,
      actor: @admin,
      event: @event,
      viewed: true
    )

    updated_at_before = notification.reload.updated_at

    MessageChannelService.stub(:publish_models, ->(*) {}) do
      NotificationService.mark_as_read(@discussion.class.to_s, @discussion.id, @user.id)
    end

    assert_equal updated_at_before, notification.reload.updated_at
  end

  test "viewed marks all unviewed notifications as viewed" do
    notification = Notification.create!(
      user: @user,
      actor: @admin,
      event: @event,
      viewed: false
    )

    MessageChannelService.stub(:publish_models, ->(*) {}) do
      NotificationService.viewed(user: @user)
    end

    assert notification.reload.viewed
  end
end
