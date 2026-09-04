require "test_helper"

class Api::V1::Mobile::RelayAuthorizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @relay_url = ENV["PUSH_RELAY_URL"]
    ENV["PUSH_RELAY_URL"] = "https://push.example.test"
    @user = User.create!(
      name: "Relay User",
      username: "relay#{SecureRandom.hex(4)}",
      email: "relay#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      password: "s3curepassword123"
    )
    @pair = authorize_device
  end

  teardown do
    @relay_url.nil? ? ENV.delete("PUSH_RELAY_URL") : ENV["PUSH_RELAY_URL"] = @relay_url
  end

  test "issues and atomically verifies a one-use relay authorization" do
    post "/api/v1/mobile/relay-authorizations", headers: bearer_headers, as: :json

    assert_response :created
    issued = JSON.parse(response.body)
    assert_equal "https://push.example.test/v1/registrations", issued["relay_registration_endpoint"]
    assert_equal 60, issued["expires_in"]
    assert_match(/\Alm_ra_[A-Za-z0-9_-]{43}\z/, issued["authorization"])
    assert_equal "no-store", response.headers["Cache-Control"]

    post "/api/v1/mobile/relay-authorizations/verify",
         params: { authorization: issued["authorization"] }, as: :json

    assert_response :success
    verified = JSON.parse(response.body)
    registration = @pair[:device].reload.mobile_push_registration
    assert_equal registration.registration_id, verified["registration_id"]
    assert_equal registration.delivery_key, verified["delivery_key"]
    refute_includes registration.delivery_key_ciphertext, verified["delivery_key"]

    post "/api/v1/mobile/relay-authorizations/verify",
         params: { authorization: issued["authorization"] }, as: :json
    assert_response :unauthorized
    assert_equal "invalid_grant", JSON.parse(response.body)["error"]
  end

  test "requires a mobile bearer token and configured HTTPS relay" do
    post "/api/v1/mobile/relay-authorizations", as: :json
    assert_response :unauthorized

    ENV.delete("PUSH_RELAY_URL")
    post "/api/v1/mobile/relay-authorizations", headers: bearer_headers, as: :json
    assert_response :service_unavailable
    assert_equal "relay_unavailable", JSON.parse(response.body)["error"]
  end

  test "rejects extra verification parameters without consuming authorization" do
    post "/api/v1/mobile/relay-authorizations", headers: bearer_headers, as: :json
    authorization = JSON.parse(response.body).fetch("authorization")

    post "/api/v1/mobile/relay-authorizations/verify",
         params: { authorization: authorization, extra: true }, as: :json
    assert_response :bad_request

    post "/api/v1/mobile/relay-authorizations/verify",
         params: { authorization: authorization }, as: :json
    assert_response :success
  end

  test "requires relay registration scope" do
    @pair[:device].mobile_access_tokens.update_all(scopes: "notifications:manage")

    post "/api/v1/mobile/relay-authorizations", headers: bearer_headers, as: :json

    assert_response :forbidden
    assert_equal "insufficient_scope", JSON.parse(response.body)["error"]
  end

  private

  def bearer_headers
    { "HTTP_AUTHORIZATION" => "Bearer #{@pair[:access_token]}" }
  end

  def authorize_device
    verifier = "v" * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: challenge)
    Mobile::AuthenticationService.exchange_authorization_code!(
      code: code,
      code_verifier: verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "Relay Test iPhone"
    )
  end
end
