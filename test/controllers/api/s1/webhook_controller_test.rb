require "test_helper"

class Api::S1::WebhookControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secret_previous = ENV["LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET"]
    @installation_previous = ENV["LOOMIO_INSTALLATION_ID"]
    ENV["LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET"] = "callback-secret"
    ENV["LOOMIO_INSTALLATION_ID"] = "loomio.example"

    user = User.create!(name: "Coordinator", email: "coordinator@example.com",
      username: "coordinator", email_verified: true)
    @group = Group.new(name: "Example Cooperative", group_privacy: "secret")
    @group.creator = user
    @group.save!
  end

  teardown do
    restore_env("LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET", @secret_previous)
    restore_env("LOOMIO_INSTALLATION_ID", @installation_previous)
  end

  test "applies a signed subscription snapshot and records its receipt" do
    assert_difference -> { SubscriptionUpdateReceipt.count }, 1 do
      post_update(payload)
    end

    assert_response :ok
    subscription = @group.reload.subscription
    assert_equal "sub_123", subscription.billing_service_subscription_id
    assert_equal "product_123", subscription.billing_service_product_id
    assert_equal "price_123", subscription.billing_service_price_point_id
    assert_equal "connected-standard", subscription.plan
    assert_equal "active", subscription.state
    assert_equal "loomio_subscriptions", subscription.payment_method
    assert_equal 100, subscription.max_members
    assert subscription.allow_subgroups
    refute subscription.allow_guests
    assert_equal "USD", subscription.info.fetch("billing_service_currency")
  end

  test "accepts a repeated delivery without applying it twice" do
    body = JSON.generate(payload)
    post_signed_body(body)

    assert_no_difference -> { SubscriptionUpdateReceipt.count } do
      post_signed_body(body)
    end

    assert_response :ok
  end

  test "rejects a reused event id with a different payload" do
    post_update(payload)
    changed = payload.deep_dup
    changed["subscription"]["state"] = "past_due"

    post_update(changed)

    assert_response :conflict
    assert_equal "active", @group.reload.subscription.state
  end

  test "rejects an invalid signature" do
    body = JSON.generate(payload)
    post api_s1_webhook_path,
      params: body,
      headers: signed_headers(body).merge("X-Loomio-Subscriptions-Signature" => "sha256=bad")

    assert_response :unauthorized
    assert_nil @group.reload.subscription
  end

  test "rejects a signed event of another type" do
    changed = payload.merge("type" => "subscription.deleted")

    post_update(changed)

    assert_response :unprocessable_entity
    assert_nil @group.reload.subscription
  end

  test "rejects a target kind that this Loomio subscription projection does not support" do
    changed = payload.deep_dup
    changed["target"] = {
      "id" => "target_seat",
      "kind" => "seat",
      "group_id" => @group.key,
      "user_id" => "user-123"
    }

    post_update(changed)

    assert_response :unprocessable_entity
    assert_nil @group.reload.subscription
  end

  test "does not overwrite a subscription that is still managed by Chargify" do
    subscription = Subscription.for(@group)
    subscription.update!(
      plan: "legacy-product",
      state: "active",
      payment_method: "chargify",
      chargify_subscription_id: 123
    )

    assert_no_difference -> { SubscriptionUpdateReceipt.count } do
      post_update(payload)
    end

    assert_response :unprocessable_entity
    subscription.reload
    assert_equal "chargify", subscription.payment_method
    assert_equal "legacy-product", subscription.plan
    assert_nil subscription.billing_service_subscription_id
  end

  private

  def payload
    {
      "event_id" => "evt_123",
      "type" => "subscription.updated",
      "occurred_at" => Time.current.iso8601,
      "installation_id" => "loomio.example",
      "organization" => { "id" => @group.key, "name" => @group.name },
      "target" => {
        "id" => "target_123",
        "kind" => "group",
        "group_id" => @group.key,
        "group_name" => @group.name
      },
      "subscription" => {
        "id" => "sub_123",
        "state" => "active",
        "product" => {
          "id" => "product_123",
          "code" => "connected-standard",
          "name" => "Standard"
        },
        "price_point" => {
          "id" => "price_123",
          "name" => "Standard monthly",
          "entitlements" => {
            "max_members" => 100,
            "max_orgs" => 1,
            "max_threads" => nil,
            "allow_subgroups" => true,
            "allow_guests" => false
          }
        },
        "currency" => "USD",
        "recurring_amount_cents" => 2_900,
        "interval_count" => 1,
        "interval_unit" => "month",
        "current_period_started_at" => Time.current.iso8601,
        "current_period_ends_at" => 1.month.from_now.iso8601,
        "next_billing_at" => 1.month.from_now.iso8601,
        "expires_at" => nil,
        "canceled_at" => nil
      }
    }
  end

  def post_update(value)
    post_signed_body(JSON.generate(value))
  end

  def post_signed_body(body)
    post api_s1_webhook_path, params: body, headers: signed_headers(body)
  end

  def signed_headers(body)
    timestamp = Time.current.to_i.to_s
    signature = OpenSSL::HMAC.hexdigest("SHA256", ENV.fetch("LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET"),
      "#{timestamp}.#{body}")
    {
      "Content-Type" => "application/json",
      "X-Loomio-Subscriptions-Event-Id" => JSON.parse(body).fetch("event_id"),
      "X-Loomio-Subscriptions-Timestamp" => timestamp,
      "X-Loomio-Subscriptions-Signature" => "sha256=#{signature}"
    }
  end

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end
