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
    stub_request(:post, "https://subscriptions.example/api/v1/sessions").to_return(
      status: 201,
      body: JSON.generate(url: "https://subscriptions.example/session/grant"),
      headers: { "Content-Type" => "application/json" }
    )

    get :show, params: { group_id: @group.id, format: :json }

    assert_redirected_to "https://subscriptions.example/session/grant"
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

  private

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end
