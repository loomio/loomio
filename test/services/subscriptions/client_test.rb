require "test_helper"

class Subscriptions::ClientTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Subscriber", email: "subscriber@example.com", username: "subscriber", email_verified: true)
    @group = Group.new(name: "Example Cooperative", group_privacy: "secret")
    @group.creator = @user
    @group.save!
  end

  test "creates a customer session with organization and user context" do
    stub_request(:post, "https://subscriptions.example/api/v1/sessions").to_return(
      status: 201,
      body: JSON.generate(url: "https://subscriptions.example/session/grant"),
      headers: { "Content-Type" => "application/json" }
    )

    url = Subscriptions::Client.new(
      base_url: "https://subscriptions.example",
      api_token: "client.token"
    ).create_session(
      group: @group,
      user: @user,
      callback_url: "https://loomio.example/api/s1/webhook",
      return_url: "https://loomio.example/g/#{@group.key}"
    )

    assert_equal "https://subscriptions.example/session/grant", url
    assert_requested(:post, "https://subscriptions.example/api/v1/sessions") do |sent|
      body = JSON.parse(sent.body).fetch("session")
      sent.headers.fetch("Authorization") == "Bearer client.token" &&
        body.dig("target", "kind") == "group" &&
        body.dig("target", "group_id") == @group.key &&
        body.dig("organization", "id") == @group.key &&
        body.dig("user", "email") == @user.email
    end
  end

  test "rejects a redirect URL on another origin" do
    stub_request(:post, "https://subscriptions.example/api/v1/sessions").to_return(
      status: 201,
      body: JSON.generate(url: "https://attacker.example/session/grant"),
      headers: { "Content-Type" => "application/json" }
    )

    assert_raises Subscriptions::Client::Error do
      Subscriptions::Client.new(
        base_url: "https://subscriptions.example",
        api_token: "client.token"
      ).create_session(
        group: @group,
        user: @user,
        callback_url: "https://loomio.example/api/s1/webhook",
        return_url: "https://loomio.example/g/#{@group.key}"
      )
    end
  end

  test "requires the configured service URL to be an origin" do
    assert_raises Subscriptions::Client::Error do
      Subscriptions::Client.new(
        base_url: "https://subscriptions.example/customer",
        api_token: "client.token"
      )
    end
  end
end
