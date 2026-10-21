require "test_helper"

class WebPushServiceTest < ActiveSupport::TestCase
  setup do
    @subscription = create_push_subscription(
      user: users(:user),
      endpoint: "https://fcm.googleapis.com/fcm/send/service-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    @environment = ENV.to_h.slice("VAPID_PUBLIC_KEY", "VAPID_PRIVATE_KEY", "VAPID_SUBJECT")
    ENV["VAPID_PUBLIC_KEY"] = "public-key"
    ENV["VAPID_PRIVATE_KEY"] = "private-key"
    ENV["VAPID_SUBJECT"] = "mailto:admin@example.test"
  end

  teardown do
    %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT].each do |key|
      @environment.key?(key) ? ENV[key] = @environment[key] : ENV.delete(key)
    end
  end

  test "successful delivery refreshes the subscription" do
    @subscription.update!(failure_count: 3, last_seen_at: 1.day.ago)
    payload = { title: "Review", url: "/dashboard" }
    delivered = nil

    freeze_time do
      WebPush.stub(:payload_send, ->(**options) { delivered = options; true }) do
        assert WebPushService.deliver!(subscription: @subscription, payload: payload)
      end

      assert_equal({
        message: payload.to_json,
        endpoint: @subscription.endpoint,
        p256dh: @subscription.p256dh_key,
        auth: @subscription.auth_key,
        vapid: {
          subject: "mailto:admin@example.test",
          public_key: "public-key",
          private_key: "private-key"
        }
      }, delivered)
      assert_equal 0, @subscription.reload.failure_count
      assert_equal Time.current, @subscription.last_seen_at
    end
  end

  test "configuration requires every VAPID setting" do
    %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT].each do |key|
      value = ENV.delete(key)

      assert_not WebPushService.configured?, "Push was enabled without #{key}"

      ENV[key] = value
    end
  end

  test "incomplete configuration prevents delivery" do
    ENV.delete('VAPID_PRIVATE_KEY')

    WebPush.stub(:payload_send, ->(**) { flunk "Attempted delivery without VAPID configuration" }) do
      error = assert_raises(RuntimeError) do
        WebPushService.deliver!(subscription: @subscription, payload: { title: "Review" })
      end

      assert_equal "Web Push is not configured", error.message
    end
  end

  test "an expired browser subscription is revoked without retrying" do
    response = Struct.new(:body).new("expired")
    WebPush.stub(:payload_send, ->(**) { raise WebPush::ExpiredSubscription.new(response, "fcm.googleapis.com") }) do
      assert_nil WebPushService.deliver!(subscription: @subscription, payload: { title: "Review" })
    end

    assert @subscription.reload.revoked_at
  end

  test "a transient failure is recorded and raised for job retry" do
    error = assert_raises(RuntimeError) do
      WebPush.stub(:payload_send, ->(**) { raise "temporarily unavailable" }) do
        WebPushService.deliver!(subscription: @subscription, payload: { title: "Review" })
      end
    end

    assert_equal "temporarily unavailable", error.message
    assert_equal 1, @subscription.reload.failure_count
    assert_nil @subscription.revoked_at
  end
end
