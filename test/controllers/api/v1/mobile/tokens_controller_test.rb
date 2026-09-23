require "test_helper"

class Api::V1::Mobile::TokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Mobile User",
      username: "mobiletoken#{SecureRandom.hex(4)}",
      email: "mobiletoken#{SecureRandom.hex(4)}@example.com",
      email_verified: true
    )
    @verifier = "v" * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(@verifier), padding: false)
    @code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: challenge)
  end

  test "exchanges and refreshes credentials over the public native-client endpoint" do
    post "/api/v1/mobile/token", params: {
      grant_type: "authorization_code",
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      code: @code,
      code_verifier: @verifier,
      device_name: "HTTP iPhone"
    }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "no-cache", response.headers["Pragma"]
    token = JSON.parse(response.body)
    assert_equal "Bearer", token["token_type"]
    assert_equal 900, token["expires_in"]
    assert_equal "HTTP iPhone", token.dig("device", "name")

    post "/api/v1/mobile/token", params: {
      grant_type: "refresh_token",
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      refresh_token: token["refresh_token"]
    }

    assert_response :success
    refreshed = JSON.parse(response.body)
    assert_not_equal token["access_token"], refreshed["access_token"]
    assert_not_equal token["refresh_token"], refreshed["refresh_token"]
  end

  test "rejects JSON token exchange bodies" do
    post "/api/v1/mobile/token", params: {
      grant_type: "authorization_code",
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      code: @code,
      code_verifier: @verifier
    }, as: :json

    assert_response :bad_request
    assert_equal "invalid_request", JSON.parse(response.body)["error"]
  end

  test "rejects duplicated token parameters" do
    body = URI.encode_www_form(
      grant_type: "authorization_code",
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      code: @code,
      code_verifier: @verifier
    ) + "&code=second-code"

    post "/api/v1/mobile/token", params: body, headers: {
      "CONTENT_TYPE" => "application/x-www-form-urlencoded"
    }

    assert_response :bad_request
    assert_equal "invalid_request", JSON.parse(response.body)["error"]
  end

  test "issues a web-session ticket only for a valid mobile bearer token" do
    pair = Mobile::AuthenticationService.exchange_authorization_code!(
      code: @code,
      code_verifier: @verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "HTTP iPhone"
    )

    post "/api/v1/mobile/web-session-tickets",
      params: {},
      headers: { "HTTP_AUTHORIZATION" => "Bearer #{pair[:access_token]}" },
      as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["ticket"].start_with?("lm_ws_")
    assert_equal 60, payload["expires_in"]
  end

  test "requires web session scope to issue a ticket" do
    pair = Mobile::AuthenticationService.exchange_authorization_code!(
      code: @code,
      code_verifier: @verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "Scoped iPhone"
    )
    pair[:device].mobile_access_tokens.update_all(scopes: "activity:read")

    post "/api/v1/mobile/web-session-tickets",
      params: {},
      headers: { "HTTP_AUTHORIZATION" => "Bearer #{pair[:access_token]}" },
      as: :json

    assert_response :forbidden
    assert_equal "insufficient_scope", JSON.parse(response.body)["error"]
  end
end
