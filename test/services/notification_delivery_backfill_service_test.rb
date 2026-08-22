require "test_helper"

class NotificationDeliveryBackfillServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @event = events(:discussion_created_event)
  end

  test "backfills event fields in bounded notification id batches" do
    first = create_legacy_notification(event: @event, user: @user, actor: nil)
    second = create_legacy_notification(event: @event, user: users(:member), actor: nil)

    stats = NotificationDeliveryBackfillService.run!(dry_run: false, batch_size: 1)

    assert_equal 2, stats[:batches]
    assert_equal 2, stats[:notifications_updated]
    [ first, second ].each do |notification|
      notification.reload
      assert_equal "new_discussion", notification.kind
      assert_equal "Discussion", notification.subject_type
      assert_equal @event.eventable_id, notification.subject_id
      assert_equal @event.user_id, notification.actor_id
      assert_equal "event:#{@event.id}", notification.deduplication_key
    end
    assert_equal({ keys_missing: 0, rows_blocked: 0, fields_incomplete: 0 }, stats[:after])
  end

  test "backfills effective announcement and reply kinds" do
    announcement_event = Event.create!(
      kind: "announcement_created",
      eventable: groups(:group),
      user: @admin,
      custom_fields: { "kind" => "poll_announced" }
    )
    announcement = create_legacy_notification(event: announcement_event, user: @user)

    comment = comments(:public_discussion_comment)
    mention_event = Event.create!(kind: "user_mentioned", eventable: comment, user: users(:alien))
    reply = create_legacy_notification(event: mention_event, user: comment.parent.author)
    mention = create_legacy_notification(event: mention_event, user: users(:member))

    NotificationDeliveryBackfillService.run!(dry_run: false, batch_size: 1)

    assert_equal "poll_announced", announcement.reload.kind
    assert_equal "comment_replied_to", reply.reload.kind
    assert_equal "user_mentioned", mention.reload.kind
  end

  test "does not overwrite self-contained fields already stored" do
    notification = create_legacy_notification(event: @event, user: @user, actor: @admin)
    notification.update_columns(
      kind: "stored_kind",
      subject_type: "Discussion",
      subject_id: discussions(:public_discussion).id
    )

    NotificationDeliveryBackfillService.run!(dry_run: false)

    notification.reload
    assert_equal "stored_kind", notification.kind
    assert_equal discussions(:public_discussion), notification.subject
    assert_equal @admin.id, notification.actor_id
    assert_equal "event:#{@event.id}", notification.deduplication_key
  end

  test "normalizes duplicates before assigning event delivery keys" do
    retained = create_legacy_notification(event: @event, user: @user, viewed: false)
    duplicate = create_legacy_notification(event: @event, user: @user, viewed: true)

    stats = NotificationDeliveryBackfillService.run!(dry_run: false)

    assert_equal 1, stats.dig(:duplicate_stats, :removed_notifications)
    assert retained.reload.viewed
    assert_equal "event:#{@event.id}", retained.deduplication_key
    assert_not Notification.exists?(duplicate.id)
  end

  test "dry run reports work without changing notifications" do
    notification = create_legacy_notification(event: @event, user: @user)

    stats = NotificationDeliveryBackfillService.run!(dry_run: true)

    assert stats[:dry_run]
    assert_equal 1, stats.dig(:before, :keys_missing)
    assert_nil notification.reload.deduplication_key
  end

  test "maintenance mode restores the index when field backfill raises" do
    calls = []

    NotificationDeliveryBackfillService.stub(:remove_deduplication_index!, -> { calls << :remove }) do
      NotificationDeliveryBackfillService.stub(:add_deduplication_index!, -> { calls << :add }) do
        NotificationDeliveryBackfillService.stub(:backfill_fields!, ->(*) { raise "backfill failed" }) do
          assert_raises(RuntimeError) do
            NotificationDeliveryBackfillService.run!(dry_run: false, rebuild_index: true)
          end
        end
      end
    end

    assert_equal %i[remove add], calls
  end

  test "honors an explicit high water notification id" do
    included = create_legacy_notification(event: @event, user: @user)
    high_water_id = included.id
    deferred = create_legacy_notification(event: @event, user: users(:member))

    NotificationDeliveryBackfillService.run!(dry_run: false, high_water_id: high_water_id)

    assert_equal "event:#{@event.id}", included.reload.deduplication_key
    assert_nil deferred.reload.deduplication_key
  end

  test "raises when event metadata cannot produce a self-contained notification" do
    event_id = Event.insert_all!([ {
      kind: "unknown_sender",
      eventable_type: nil,
      eventable_id: nil,
      user_id: @admin.id,
      created_at: Time.current,
      updated_at: Time.current
    } ]).rows.first.first
    notification = create_legacy_notification(event: Event.find(event_id), user: @user)

    error = assert_raises(NotificationDeliveryBackfillService::IncompleteBackfill) do
      NotificationDeliveryBackfillService.run!(dry_run: false)
    end

    assert_includes error.message, "rows_blocked: 1"
    assert_nil notification.reload.deduplication_key
  end

  private

  def create_legacy_notification(event:, user:, actor: @admin, viewed: false)
    Notification.create!(event: event, user: user, actor: actor, viewed: viewed).tap do |notification|
      notification.update_columns(
        kind: nil,
        subject_type: nil,
        subject_id: nil,
        deduplication_key: nil
      )
    end
  end
end
