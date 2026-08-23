require "test_helper"

class NotificationDeliveryTest < ActiveSupport::TestCase
  setup do
    @notification = Notification.create!(
      actor: users(:admin),
      kind: "new_discussion",
      subject: discussions(:discussion),
      deduplication_key: "new_discussion:delivery-test:#{SecureRandom.uuid}"
    )
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @chatbot = Chatbot.create!(
        group: groups(:group),
        author: users(:admin),
        name: "Delivery test chatbot",
        server: "https://delivery-test.example.test/hook",
        webhook_kind: "markdown",
        kind: "webhook"
      )
    end
  end

  test "one notification has at most one delivery per channel and recipient" do
    attributes = {
      notification: @notification,
      recipient: @chatbot,
      channel: "chatbot"
    }
    NotificationDelivery.create!(attributes)

    assert_raises(ActiveRecord::RecordInvalid) do
      NotificationDelivery.create!(attributes)
    end
  end

  test "the database rejects duplicate chatbot deliveries" do
    attributes = {
      notification_id: @notification.id,
      recipient_type: "Chatbot",
      recipient_id: @chatbot.id,
      channel: "chatbot",
      status: "pending",
      available_at: Time.current,
      created_at: Time.current,
      updated_at: Time.current
    }
    NotificationDelivery.insert_all!([ attributes ])

    assert_raises(ActiveRecord::RecordNotUnique) do
      NotificationDelivery.insert_all!([ attributes ])
    end
  end

  test "one notification can deliver to several users" do
    first_delivery = NotificationDelivery.create!(
      notification: @notification,
      recipient: users(:user),
      channel: "email"
    )
    second_delivery = NotificationDelivery.create!(
      notification: @notification,
      recipient: users(:admin),
      channel: "email"
    )

    assert_predicate first_delivery, :persisted?
    assert_predicate second_delivery, :persisted?
  end

  test "a global notification has one identity and recipient-specific view state" do
    subject = topic_items(:discussion_created_topic_item).itemable
    notification = Notification.create!(
      actor: users(:admin),
      kind: "discussion_edited",
      subject: subject,
      deduplication_key: "discussion_edited:discussion_#{subject.id}:2026-08-22"
    )
    viewed_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: users(:user),
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current,
      viewed_at: Time.current
    )
    unviewed_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: users(:member),
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )

    assert_includes Notification.pending_delivery_resolution, notification
    assert_predicate viewed_delivery, :viewed?
    assert_not_predicate unviewed_delivery, :viewed?

    notification.update!(deliveries_generated_at: Time.current)
    assert_not_includes Notification.pending_delivery_resolution, notification
  end

  test "the database rejects a duplicate global notification identity" do
    subject = topic_items(:discussion_created_topic_item).itemable
    attributes = {
      actor_id: users(:admin).id,
      kind: "discussion_edited",
      subject_type: subject.class.base_class.name,
      subject_id: subject.id,
      deduplication_key: "discussion_edited:discussion_#{subject.id}:2026-08-23",
      translation_values: {},
      created_at: Time.current,
      updated_at: Time.current
    }
    Notification.insert_all!([ attributes ])

    assert_raises(ActiveRecord::RecordNotUnique) do
      Notification.insert_all!([ attributes ])
    end
  end

  test "a notification must be self-contained" do
    notification = Notification.new(actor: users(:admin), kind: "outcome_review_due")

    assert_not notification.valid?
    assert notification.errors[:subject].any?
  end

  test "the database rejects an incomplete notification" do
    assert_raises(ActiveRecord::StatementInvalid) do
      Notification.insert_all!([ {
        actor_id: users(:admin).id,
        kind: "outcome_review_due",
        translation_values: {},
        created_at: Time.current,
        updated_at: Time.current
      } ])
    end
  end

  test "available excludes claimed, cancelled and future retry deliveries" do
    available = NotificationDelivery.create!(
      notification: @notification,
      recipient: users(:user),
      channel: "email"
    )
    NotificationDelivery.create!(
      notification: @notification,
      recipient: @chatbot,
      channel: "chatbot",
      status: "claimed"
    )
    NotificationDelivery.create!(
      notification: @notification,
      recipient: users(:member),
      channel: "push",
      status: "failed",
      next_attempt_at: 1.hour.from_now
    )

    assert_equal [ available ], NotificationDelivery.available.to_a
  end

  test "deleting a notification cascades to deliveries" do
    delivery = NotificationDelivery.create!(
      notification: @notification,
      recipient: @chatbot,
      channel: "chatbot"
    )

    Notification.where(id: @notification.id).delete_all

    assert_not NotificationDelivery.exists?(delivery.id)
  end
end
