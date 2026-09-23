require "test_helper"

class DeliverTestPushWorkerTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @subscription = create_push_subscription(
      user: @user,
      endpoint: "https://fcm.googleapis.com/fcm/send/test-worker-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
  end

  test "delivers the localized test payload" do
    delivery = nil

    WebPushService.stub(:deliver!, ->(**args) { delivery = args; true }) do
      DeliverTestPushWorker.perform_now(@subscription.id)
    end

    assert_equal @subscription, delivery[:subscription]
    assert_equal I18n.t("push_notifications.title", locale: @user.locale), delivery.dig(:payload, :title)
    assert_equal I18n.t("push_notifications.enabled", locale: @user.locale), delivery.dig(:payload, :body)
    assert_equal "/email_preferences", delivery.dig(:payload, :data, :url)
  end

  test "does not deliver to an inactive subscription" do
    @subscription.revoke!

    assert_no_changes -> { @subscription.reload.failure_count } do
      WebPushService.stub(:deliver!, ->(**) { flunk "test push should not be sent" }) do
        DeliverTestPushWorker.perform_now(@subscription.id)
      end
    end
  end
end
