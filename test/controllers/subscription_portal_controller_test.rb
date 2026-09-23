require "test_helper"

class SubscriptionPortalControllerTest < ActionController::TestCase
  setup do
    @controller = SubscriptionPortalController.new
    @routes = Rails.application.routes
    @url_previous = ENV["LOOMIO_SUBSCRIPTIONS_URL"]
    @token_previous = ENV["LOOMIO_SUBSCRIPTIONS_API_TOKEN"]
    ENV["LOOMIO_SUBSCRIPTIONS_URL"] = "https://subscriptions.example"
    ENV["LOOMIO_SUBSCRIPTIONS_API_TOKEN"] = "client.token"

    suffix = SecureRandom.hex(4)
    @user = User.create!(name: "Coordinator", email: "coordinator-#{suffix}@example.com",
      username: "coordinator-#{suffix}", email_verified: true)
    @group = Group.new(name: "Example Cooperative", group_privacy: "secret")
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)
    sign_in @user
  end

  teardown do
    restore_env("LOOMIO_SUBSCRIPTIONS_URL", @url_previous)
    restore_env("LOOMIO_SUBSCRIPTIONS_API_TOKEN", @token_previous)
  end

  test "redirects an organization coordinator to the subscription service" do
    stub_portal_session

    get :show, params: { group_id: @group.id, format: :json }

    assert_redirected_to "https://subscriptions.example/session/grant"
  end

  test "manages a Loomio subscription through the hosted customer portal" do
    @group.update!(subscription: Subscription.create!(owner: @user, payment_method: "loomio_subscriptions"))
    stub_portal_session

    get :manage, params: { group_id: @group.id, format: :json }

    assert_redirected_to "https://subscriptions.example/session/grant"
  end

  test "manages a Chargify subscription through the existing upgrade flow" do
    @group.update!(subscription: Subscription.create!(owner: @user, payment_method: "chargify"))

    get :manage, params: { group_id: @group.id }

    assert_redirected_to "/upgrade/#{@group.id}"
    assert_not_requested :post, "https://subscriptions.example/api/v1/sessions"
  end

  test "lists subscription links when the coordinator administers several organizations" do
    other_group = Group.new(name: "Other Cooperative", group_privacy: "secret")
    other_group.creator = @user
    other_group.save!
    other_group.add_admin!(@user)

    get :index

    assert_response :success
    assert_select "a[href='#{subscription_portal_group_path(@group.id)}']", @group.full_name
    assert_select "a[href='#{subscription_portal_group_path(other_group.id)}']", other_group.full_name
  end

  test "does not send a non-coordinator to the subscription service" do
    suffix = SecureRandom.hex(4)
    other = User.create!(name: "Member", email: "member-#{suffix}@example.com",
      username: "member-#{suffix}", email_verified: true)
    @group.add_member!(other)
    sign_in other

    get :show, params: { group_id: @group.id, format: :json }

    assert_response :not_found
  end

  test "does not expose either management flow to a non-coordinator" do
    @group.update!(subscription: Subscription.create!(owner: @user, payment_method: "loomio_subscriptions"))
    suffix = SecureRandom.hex(4)
    other = User.create!(name: "Member", email: "member-#{suffix}@example.com",
      username: "member-#{suffix}", email_verified: true)
    @group.add_member!(other)
    sign_in other

    get :manage, params: { group_id: @group.id, format: :json }

    assert_response :not_found
    assert_not_requested :post, "https://subscriptions.example/api/v1/sessions"
  end

  test "requires a Loomio session before choosing a management flow" do
    @group.update!(subscription: Subscription.create!(owner: @user, payment_method: "loomio_subscriptions"))
    sign_out

    get :manage, params: { group_id: @group.id }

    assert_redirected_to dashboard_path
    assert_not_requested :post, "https://subscriptions.example/api/v1/sessions"
  end

  private

  def stub_portal_session
    stub_request(:post, "https://subscriptions.example/api/v1/sessions").to_return(
      status: 201,
      body: JSON.generate(url: "https://subscriptions.example/session/grant"),
      headers: { "Content-Type" => "application/json" }
    )
  end

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end
