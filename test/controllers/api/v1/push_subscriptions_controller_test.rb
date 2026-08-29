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
    assert_equal Current.session, subscription.session
    assert_nil response.parsed_body.dig("push_subscriptions", 0, "endpoint")

    delete :destroy, params: { endpoint: subscription.endpoint }

    assert_response :success
    assert subscription.reload.revoked_at
  end

  test "moves an existing browser endpoint to the newly signed-in account and session" do
    old_user = users(:member)
    old_session = old_user.sessions.create!(user_agent: "old browser", ip_address: "127.0.0.2")
    old_subscription = PushSubscriptionService.create_or_update!(
      session: old_session,
      params: subscription_params,
      user_agent: "old browser"
    )

    post :create, params: { push_subscription: subscription_params.merge(auth_key: "new-auth") }

    assert_response :success
    new_subscription = @user.push_subscriptions.active.find_by!(endpoint_digest: old_subscription.endpoint_digest)
    assert old_subscription.reload.revoked_at
    refute_equal old_subscription.id, new_subscription.id
    assert_equal Current.session, new_subscription.session
    assert_equal "new-auth", new_subscription.auth_key
  end

  test "moves an existing endpoint to the current session for the same account" do
    old_session = @user.sessions.create!(user_agent: "old browser", ip_address: "127.0.0.2")
    subscription = create_push_subscription(
      user: @user,
      session: old_session,
      **subscription_params
    )

    post :create, params: { push_subscription: subscription_params.merge(auth_key: "new-auth") }

    assert_response :success
    assert_equal Current.session, subscription.reload.session
    assert_equal "new-auth", subscription.auth_key
  end

  test "rejects an arbitrary delivery endpoint" do
    assert_no_difference "PushSubscription.count" do
      post :create, params: {
        push_subscription: subscription_params.merge(endpoint: "https://example.test/internal")
      }
    end

    assert_response :unprocessable_entity
  end

  test "returns not found when revoking an unknown subscription" do
    delete :destroy, params: { endpoint: subscription_params[:endpoint] }

    assert_response :not_found
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
