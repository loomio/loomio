require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  test "session determines its user" do
    session = users(:member).sessions.create!(user_agent: "test browser")
    subscription = PushSubscription.new(
      user: users(:user),
      session: session,
      endpoint: "https://fcm.googleapis.com/fcm/send/session-user-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    subscription.save!

    assert_equal session.user, subscription.reload.user
  end

  test "notification jobs send only to unexpired and unrevoked browser subscriptions" do
    subscription = create_push_subscription(user: users(:member),
      endpoint: 'https://fcm.googleapis.com/fcm/send/notification-lifecycle',
      p256dh_key: 'p256dh-key', auth_key: 'auth-key')
    notification = Notification.create!(kind: 'discussion_edited', subject: discussions(:discussion),
      actor: users(:user), recipient_user_ids: [subscription.user_id])
    delivery = NotificationDelivery.create!(notification: notification, recipient: subscription, channel: 'push')
    sent = []

    freeze_time do
      WebPushService.stub(:deliver!, ->(**args) { sent << args.fetch(:subscription).id; true }) do
        [{expires_at: Time.current}, {expires_at: 1.second.ago},
         {expires_at: 1.day.from_now, revoked_at: Time.current}].each do |state|
          subscription.update!(state)
          DeliverNotificationPushWorker.perform_now(delivery.id)
          assert_empty sent
          assert_nil delivery.reload.delivered_at
        end

        subscription.update!(expires_at: 1.second.from_now, revoked_at: nil)
        DeliverNotificationPushWorker.perform_now(delivery.id)
        assert_equal [subscription.id], sent
        assert_equal Time.current, delivery.reload.delivered_at
      end
    end
  end
end
