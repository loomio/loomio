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

  test "reconciliation does not create an unknown browser subscription" do
    assert_no_difference "PushSubscription.count" do
      post :reconcile, params: { push_subscription: subscription_params }
    end

    assert_response :success
    assert_equal false, response.parsed_body["enabled"]
  end

  test "reconciliation does not reactivate a removed browser subscription" do
    subscription = create_push_subscription(user: @user, session: Current.session, **subscription_params)
    delete :destroy, params: { id: subscription.id }

    assert_response :success
    assert_no_difference "PushSubscription.count" do
      post :reconcile, params: { push_subscription: subscription_params.merge(auth_key: "new-auth") }
    end

    assert_response :success
    assert_equal false, response.parsed_body["enabled"]
    assert subscription.reload.revoked_at
  end

  test "explicit enable creates a replacement for a revoked subscription" do
    subscription = create_push_subscription(user: @user, session: Current.session, **subscription_params)
    subscription.revoke!

    assert_difference "PushSubscription.count", 1 do
      post :create, params: { push_subscription: subscription_params.merge(auth_key: "new-auth") }
    end

    assert_response :success
    enabled = @user.push_subscriptions.active.find_by!(endpoint_digest: subscription.endpoint_digest)
    assert_equal "new-auth", enabled.auth_key
  end

  test "reconciliation preserves the device name while refreshing the current session subscription" do
    subscription = create_push_subscription(
      user: @user,
      session: Current.session,
      name: "Laptop browser",
      **subscription_params
    )

    post :reconcile, params: { push_subscription: subscription_params.merge(auth_key: "new-auth") }

    assert_response :success
    assert_equal Current.session, subscription.reload.session
    assert_equal "new-auth", subscription.auth_key
    assert_equal "Laptop browser", subscription.name
  end

  test "reconciliation disables a subscription owned by another session for the same user" do
    old_session = @user.sessions.create!(user_agent: "old browser", ip_address: "127.0.0.2")
    subscription = create_push_subscription(user: @user, session: old_session, **subscription_params)

    post :reconcile, params: { push_subscription: subscription_params }

    assert_response :success
    assert_equal false, response.parsed_body["enabled"]
    assert subscription.reload.revoked_at
  end

  test "reconciliation does not revoke another user's subscription" do
    old_user = users(:member)
    subscription = create_push_subscription(user: old_user, **subscription_params)

    post :reconcile, params: { push_subscription: subscription_params }

    assert_response :success
    assert_equal false, response.parsed_body["enabled"]
    assert_nil subscription.reload.revoked_at
  end

  test "rejects an arbitrary delivery endpoint" do
    assert_no_difference "PushSubscription.count" do
      post :create, params: {
        push_subscription: subscription_params.merge(endpoint: "https://example.test/internal")
      }
    end

    assert_response :unprocessable_entity
  end

  test "lists only the current user's active subscriptions" do
    current_subscription = create_push_subscription(user: @user, **subscription_params)
    other_user = users(:member)
    create_push_subscription(
      user: other_user,
      **subscription_params.merge(endpoint: "https://fcm.googleapis.com/fcm/send/other-user-token")
    )

    get :index

    assert_response :success
    assert_equal [current_subscription.id], response.parsed_body.fetch("push_subscriptions").pluck("id")
  end

  test "does not revoke another user's subscription" do
    other_user = users(:member)
    subscription = create_push_subscription(user: other_user, **subscription_params)

    delete :destroy, params: { id: subscription.id }

    assert_response :not_found
    assert_nil subscription.reload.revoked_at
  end

  test "requires sign in to revoke a subscription" do
    subscription = create_push_subscription(user: @user, **subscription_params)
    sign_out @user

    delete :destroy, params: { id: subscription.id }

    assert_response :unauthorized
    assert_nil subscription.reload.revoked_at
  end

  test "returns not found when revoking an unknown subscription" do
    delete :destroy, params: { endpoint: subscription_params[:endpoint] }

    assert_response :not_found
  end

  test "sends a test notification to every active user subscription" do
    current_subscription = create_push_subscription(
      user: @user,
      session: Current.session,
      **subscription_params.merge(endpoint: "https://fcm.googleapis.com/fcm/send/current-browser-token")
    )
    other_session = @user.sessions.create!(user_agent: "other browser", ip_address: "127.0.0.2")
    other_subscription = create_push_subscription(
      user: @user,
      session: other_session,
      **subscription_params.merge(endpoint: "https://fcm.googleapis.com/fcm/send/other-browser-token")
    )

    assert_enqueued_with(job: DeliverTestPushWorker, args: [current_subscription.id]) do
      assert_enqueued_with(job: DeliverTestPushWorker, args: [other_subscription.id]) do
        post :send_test
      end
    end

    assert_response :success
  end

  test "does not send a test notification to another user subscription" do
    other_user = users(:member)
    create_push_subscription(user: other_user, **subscription_params)

    assert_no_enqueued_jobs(only: DeliverTestPushWorker) do
      post :send_test
    end

    assert_response :success
  end

  test "requires sign in to send a test notification" do
    sign_out @user

    assert_no_enqueued_jobs(only: DeliverTestPushWorker) do
      post :send_test
    end

    assert_response :unauthorized
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
