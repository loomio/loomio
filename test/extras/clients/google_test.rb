require 'test_helper'

class Clients::GoogleTest < ActiveSupport::TestCase
  test "exchanges an authorization code for an access token" do
    WebMock.stub_request(:post, "https://www.googleapis.com/oauth2/v4/token").
      with(body: {
        client_id: "client-id",
        client_secret: "client-secret",
        code: "authorization-code",
        redirect_uri: "https://loomio.test/oauth/callback",
        grant_type: "authorization_code"
      }).
      to_return(status: 200, body: { access_token: "access-token" }.to_json)

    client = Clients::Google.new(key: "client-id", secret: "client-secret")

    assert_equal "access-token", client.fetch_access_token("authorization-code", "https://loomio.test/oauth/callback")
  end

  test "fetches identity attributes with the access token" do
    WebMock.stub_request(:get, "https://www.googleapis.com/oauth2/v2/userinfo").
      with(query: {
        client_id: "client-id",
        client_secret: "client-secret",
        oauth_token: "access-token"
      }).
      to_return(status: 200, body: {
        id: "google-user-id",
        name: "Pat Example",
        email: "pat@example.test",
        picture: "https://example.test/pat.png"
      }.to_json)

    client = Clients::Google.new(key: "client-id", secret: "client-secret", token: "access-token")

    assert_equal({
      uid: "google-user-id",
      name: "Pat Example",
      email: "pat@example.test",
      logo: "https://example.test/pat.png",
      identity_type: "google"
    }, client.fetch_identity_params)
  end
end
