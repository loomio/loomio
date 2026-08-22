require "test_helper"

class NotificationDuplicateCleanupServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @other_user = users(:member)
    @event = events(:discussion_created_event)
    @other_event = events(:public_discussion_created_event)
  end

  test "retains the earliest notification and merges viewed state and updated time" do
    created_at = 3.days.ago.change(usec: 0)
    retained_id = insert_notification(
      user: @user,
      event: @event,
      actor: users(:admin),
      viewed: false,
      translation_values: { title: "Original" },
      created_at: created_at,
      updated_at: 2.days.ago.change(usec: 0)
    )
    viewed_duplicate_id = insert_notification(
      user: @user,
      event: @event,
      actor: users(:alien),
      viewed: true,
      translation_values: { title: "Duplicate" },
      created_at: 1.day.ago.change(usec: 0),
      updated_at: 1.day.ago.change(usec: 0)
    )
    latest_duplicate_id = insert_notification(
      user: @user,
      event: @event,
      viewed: false,
      created_at: 1.hour.ago.change(usec: 0),
      updated_at: Time.current.change(usec: 0)
    )
    latest_updated_at = Notification.find(latest_duplicate_id).updated_at

    stats = NotificationDuplicateCleanupService.normalize!(event_id_batch_size: 1)

    retained = Notification.find(retained_id)
    assert_equal 1, stats[:duplicate_groups]
    assert_equal 2, stats[:removed_notifications]
    assert retained.viewed
    assert_equal latest_updated_at, retained.updated_at
    assert_equal created_at, retained.created_at
    assert_equal users(:admin).id, retained.actor_id
    assert_equal({ "title" => "Original" }, retained.translation_values)
    assert_not Notification.exists?(viewed_duplicate_id)
    assert_not Notification.exists?(latest_duplicate_id)
  end

  test "normalizes each user and event independently" do
    retained_id = insert_notification(user: @user, event: @event)
    duplicate_id = insert_notification(user: @user, event: @event)
    other_user_id = insert_notification(user: @other_user, event: @event)
    other_event_id = insert_notification(user: @user, event: @other_event)

    NotificationDuplicateCleanupService.normalize!(event_id_batch_size: 1)

    assert Notification.exists?(retained_id)
    assert_not Notification.exists?(duplicate_id)
    assert Notification.exists?(other_user_id)
    assert Notification.exists?(other_event_id)
  end

  test "can be retried after duplicates have already been normalized" do
    insert_notification(user: @user, event: @event)
    insert_notification(user: @user, event: @event)

    NotificationDuplicateCleanupService.normalize!
    stats = NotificationDuplicateCleanupService.normalize!

    assert_equal 0, stats[:duplicate_groups]
    assert_equal 0, stats[:removed_notifications]
  end

  test "report counts duplicate groups and removable rows without mutation" do
    insert_notification(user: @user, event: @event)
    insert_notification(user: @user, event: @event)
    insert_notification(user: @user, event: @event)
    insert_notification(user: @other_user, event: @event)
    insert_notification(user: @other_user, event: @event)

    report = NotificationDuplicateCleanupService.report

    assert_equal({ duplicate_groups: 2, duplicate_notifications: 3 }, report)
    assert_equal 5, Notification.where(event: @event, user: [ @user, @other_user ]).count
  end

  test "rejects a non-positive event id batch size" do
    assert_raises(ArgumentError) do
      NotificationDuplicateCleanupService.normalize!(event_id_batch_size: 0)
    end
  end

  private

  def insert_notification(user:, event:, actor: nil, viewed: false, translation_values: {}, created_at: 2.days.ago, updated_at: 1.day.ago)
    Notification.insert_all!([ {
      user_id: user.id,
      event_id: event.id,
      actor_id: actor&.id,
      viewed: viewed,
      translation_values: translation_values,
      created_at: created_at,
      updated_at: updated_at
    } ]).rows.first.first
  end
end
