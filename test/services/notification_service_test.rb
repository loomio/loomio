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

    MessageChannelService.stub(:publish_models, ->(*) { }) do
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

    MessageChannelService.stub(:publish_models, ->(*) { }) do
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

    MessageChannelService.stub(:publish_models, ->(*) { }) do
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

    MessageChannelService.stub(:publish_models, ->(*) { }) do
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

    MessageChannelService.stub(:publish_models, ->(*) { }) do
      NotificationService.viewed(user: @user)
    end

    assert notification.reload.viewed
  end

  test "create_for_event stores compatibility fields and inserts each recipient once" do
    first = Notification.new(
      event: @event,
      user: @user,
      actor: @admin,
      translation_values: { title: "Discussion" }
    )

    created = NotificationService.create_for_event!(event: @event, notifications: [ first ])
    retried = NotificationService.create_for_event!(event: @event, notifications: [ first ])

    assert_equal 1, created.length
    assert_empty retried
    notification = created.first
    assert_equal "new_discussion", notification.kind
    assert_equal @discussion, notification.subject
    assert_equal @discussion, notification.eventable
    assert_equal "event:#{@event.id}", notification.deduplication_key
    assert_equal({ "title" => "Discussion" }, notification.translation_values)
    assert_equal 1, Notification.where(user: @user, deduplication_key: notification.deduplication_key).count
  end

  test "create_for_event adopts a legacy event-backed notification without redelivering it" do
    legacy = Notification.create!(event: @event, user: @user, actor: @admin)
    candidate = Notification.new(event: @event, user: @user, actor: @admin)

    created = NotificationService.create_for_event!(event: @event, notifications: [ candidate ])

    assert_empty created
    assert_equal "new_discussion", legacy.reload.kind
    assert_equal @discussion, legacy.subject
    assert_equal "event:#{@event.id}", legacy.deduplication_key
    assert_equal 1, Notification.where(event: @event, user: @user).count
  end

  test "create_for_event rejects a notification built for another event" do
    notification = Notification.new(
      event: events(:public_discussion_created_event),
      user: @user,
      actor: @admin
    )

    assert_raises(ArgumentError) do
      NotificationService.create_for_event!(event: @event, notifications: [ notification ])
    end
  end

  test "create_for_event preserves event-backed insertion before delivery fields exist" do
    notification = Notification.new(event: @event, user: @user, actor: @admin)

    NotificationService.stub(:delivery_fields_available?, false) do
      created = NotificationService.create_for_event!(event: @event, notifications: [ notification ])

      assert_equal [ notification ], created
    end

    assert notification.persisted?
    assert_nil notification.deduplication_key
  end
end
