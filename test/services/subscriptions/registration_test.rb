require "test_helper"

class Subscriptions::RegistrationTest < ActiveSupport::TestCase
  setup do
    @api_token_previous = ENV.delete("LOOMIO_SUBSCRIPTIONS_API_TOKEN")
  end

  teardown do
    @api_token_previous.nil? ? ENV.delete("LOOMIO_SUBSCRIPTIONS_API_TOKEN") :
      ENV["LOOMIO_SUBSCRIPTIONS_API_TOKEN"] = @api_token_previous
  end

  test "registers with the identity derived by this Loomio installation" do
    stub_request(:post, "https://subscriptions.example/api/v1/loomio_host_registrations").to_return(
      status: 200,
      body: JSON.generate(status: "active", id: "host_example"),
      headers: { "Content-Type" => "application/json" }
    )

    assert Subscriptions::Registration.new(base_url: "https://subscriptions.example").register!
    assert_requested(:post, "https://subscriptions.example/api/v1/loomio_host_registrations", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }) do |request|
      body = JSON.parse(request.body)
      body.fetch("installation_id") == Subscriptions::Identity.installation_id &&
        body.fetch("registration_secret") == Subscriptions::Identity.integration_secret &&
        body.fetch("base_url") == Subscriptions::Identity.canonical_origin
    end
  end

  test "production accepts HTTPS origins and rejects HTTP before registering" do
    Rails.stub(:env, ActiveSupport::StringInquirer.new('production')) do
      assert Subscriptions::Registration.new(base_url: 'https://subscriptions.example')
      assert_raises(Subscriptions::Registration::Error) do
        Subscriptions::Registration.new(base_url: 'http://subscriptions.example')
      end
    end
  end

  test "an HTTP error with an active-looking body and an inactive success response cannot register" do
    [[503, 'active'], [200, 'pending']].each do |status, state|
      stub_request(:post, 'https://subscriptions.example/api/v1/loomio_host_registrations')
        .to_return(status: status, body: JSON.generate(status: state))
      assert_raises(Subscriptions::Registration::Error) do
        Subscriptions::Registration.new(base_url: 'https://subscriptions.example').register!
      end
    end
  end

  test "configured API credentials skip self-registration" do
    ENV['LOOMIO_SUBSCRIPTIONS_API_TOKEN'] = 'configured.token'
    assert Subscriptions::Registration.new(base_url: 'https://subscriptions.example').register!
    assert_not_requested :post, 'https://subscriptions.example/api/v1/loomio_host_registrations'
  end

  test "requires the service URL to be an origin" do
    assert_raises(Subscriptions::Registration::Error) do
      Subscriptions::Registration.new(base_url: "https://subscriptions.example/customer")
    end
  end
end
