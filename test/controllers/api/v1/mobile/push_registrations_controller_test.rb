require "test_helper"

class Api::V1::Mobile::PushRegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Push User",
      username: "push#{SecureRandom.hex(4)}",
      email: "push#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      password: "s3curepassword123"
    )
    @pair = authorize_device
  end

  test "reports whether this device has a relay registration" do
    get "/api/v1/mobile/push-registration", headers: bearer_headers
    assert_response :success
    assert_equal({ "registered" => false }, JSON.parse(response.body))

    create_registration
    get "/api/v1/mobile/push-registration", headers: bearer_headers
    assert_response :success
    assert_equal({ "registered" => true }, JSON.parse(response.body))
  end

  test "sends a generic test event only for the authenticated device" do
    registration = create_registration
    captured = nil

    Mobile::RelayService.stub(:send_test!, ->(registration:) { captured = registration }) do
      post "/api/v1/mobile/push-registration/test",
           params: {},
           headers: bearer_headers,
           as: :json
    end

    assert_response :accepted
    assert_equal registration, captured
  end

  test "rejects missing registrations and nonempty request bodies" do
    post "/api/v1/mobile/push-registration/test",
         params: {},
         headers: bearer_headers,
         as: :json
    assert_response :bad_request

    create_registration
    post "/api/v1/mobile/push-registration/test",
         params: { message: "host-controlled text" },
         headers: bearer_headers,
         as: :json
    assert_response :bad_request
  end

  test "does not expose relay failures" do
    create_registration

    Mobile::RelayService.stub(:send_test!, ->(**) { raise Mobile::RelayService::Error, "internal detail" }) do
      post "/api/v1/mobile/push-registration/test",
           params: {},
           headers: bearer_headers,
           as: :json
    end

    assert_response :service_unavailable
    assert_equal "temporarily_unavailable", JSON.parse(response.body)["error"]
    refute_includes response.body, "internal detail"
  end

  test "requires notification management scope" do
    @pair[:device].mobile_access_tokens.update_all(scopes: "activity:read")

    get "/api/v1/mobile/push-registration", headers: bearer_headers

    assert_response :forbidden
    assert_equal "insufficient_scope", JSON.parse(response.body)["error"]
  end

  private

  def create_registration
    @pair[:device].create_mobile_push_registration!(
      registration_id: SecureRandom.uuid,
      delivery_key_ciphertext: Mobile::RelayCredentialCipher.encrypt(SecureRandom.urlsafe_base64(32, false))
    )
  end

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
      device_name: "Push Test iPhone"
    )
  end
end
