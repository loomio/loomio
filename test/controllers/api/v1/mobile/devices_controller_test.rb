require "test_helper"

class Api::V1::Mobile::DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Mobile User",
      username: "mobiledevice#{SecureRandom.hex(4)}",
      email: "mobiledevice#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      password: "s3curepassword123"
    )
  end

  test "does not accept an ordinary browser cookie" do
    post "/api/v1/sessions", params: { user: { email: @user.email, password: "s3curepassword123" } }
    assert_response :success

    get "/api/v1/mobile/device"

    assert_response :unauthorized
    assert_equal "invalid_token", JSON.parse(response.body)["error"]
  end

  test "shows and disconnects the bearer token device" do
    pair = authorize_device
    headers = { "HTTP_AUTHORIZATION" => "Bearer #{pair[:access_token]}" }

    get "/api/v1/mobile/device", headers: headers
    assert_response :success
    assert_equal pair[:device].id, JSON.parse(response.body)["id"]

    delete "/api/v1/mobile/device", headers: headers
    assert_response :no_content
    assert pair[:device].reload.revoked_at
  end

  test "requires device revocation scope to disconnect" do
    pair = authorize_device
    pair[:device].mobile_access_tokens.update_all(scopes: "activity:read")

    delete "/api/v1/mobile/device", headers: { "HTTP_AUTHORIZATION" => "Bearer #{pair[:access_token]}" }

    assert_response :forbidden
    assert_equal "insufficient_scope", JSON.parse(response.body)["error"]
    assert pair[:device].reload.active?
  end

  private

  def authorize_device
    verifier = "v" * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: challenge)
    Mobile::AuthenticationService.exchange_authorization_code!(
      code: code,
      code_verifier: verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "Test iPhone"
    )
  end
end
