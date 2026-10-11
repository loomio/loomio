require "test_helper"

class DemoEmailDeliveryTest < ActiveSupport::TestCase
  test "demo recipients keep in app and push notifications without email jobs" do
    recipient = users(:guest_normal)
    recipient.update!(email: "alex@oatmilk.example")
    subscription = create_push_subscription(
      user: recipient,
      endpoint: "https://fcm.googleapis.com/fcm/send/demo-guest-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    assert_no_enqueued_jobs only: DeliverNotificationEmailWorker do
      notification = route_mention(recipient)
      assert_equal [ "in_app" ], notification.notification_deliveries.where(recipient: recipient).pluck(:channel)
      assert_equal [ "push" ], notification.notification_deliveries.where(recipient: subscription).pluck(:channel)
    end

    recipient.update!(email: "alex@example.com")
    notification = route_mention(recipient)
    assert_equal %w[email in_app], notification.notification_deliveries.where(recipient: recipient).order(:channel).pluck(:channel)
  end

  private

  def route_mention(recipient)
    notification = NotificationService.create!(
      kind: "user_mentioned",
      subject: topic_items(:discussion_created_topic_item),
      actor: users(:user),
      recipient_user_ids: [ recipient.id ]
    )
    NotificationDeliveryRouter.for(notification).route!
    notification
  end
end
