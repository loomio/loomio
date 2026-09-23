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
end
