require "test_helper"

class Api::V1::PushSubscriptionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    sign_in @user
  end

  test "registers and revokes the current browser subscription" do
    assert_difference "PushSubscription.count", 1 do
      post :create, params: { push_subscription: subscription_params }
    end

    assert_response :success
    subscription = @user.push_subscriptions.last
    assert_equal "https://fcm.googleapis.com/fcm/send/browser-token", subscription.endpoint
    assert_nil response.parsed_body.dig("push_subscriptions", 0, "endpoint")

    delete :destroy, params: { endpoint: subscription.endpoint }

    assert_response :success
    assert subscription.reload.revoked_at
  end

  test "moves an existing browser endpoint to the newly signed-in account" do
    old_subscription = PushSubscriptionService.create_or_update!(
      user: users(:member),
      params: subscription_params,
      user_agent: "old browser"
    )

    post :create, params: { push_subscription: subscription_params.merge(auth_key: "new-auth") }

    assert_response :success
    new_subscription = @user.push_subscriptions.active.find_by!(endpoint_digest: old_subscription.endpoint_digest)
    assert old_subscription.reload.revoked_at
    refute_equal old_subscription.id, new_subscription.id
    assert_equal "new-auth", new_subscription.auth_key
  end

  test "rejects an arbitrary delivery endpoint" do
    assert_no_difference "PushSubscription.count" do
      post :create, params: {
        push_subscription: subscription_params.merge(endpoint: "https://example.test/internal")
      }
    end

    assert_response :unprocessable_entity
  end

  private

  def subscription_params
    {
      endpoint: "https://fcm.googleapis.com/fcm/send/browser-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    }
  end
end
