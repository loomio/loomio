require "test_helper"

class Mobile::AuthenticationServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Mobile User",
      username: "mobile#{SecureRandom.hex(4)}",
      email: "mobile#{SecureRandom.hex(4)}@example.com",
      email_verified: true
    )
    @verifier = "v" * 43
    @challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(@verifier), padding: false)
  end

  test "exchanges a PKCE authorization code exactly once" do
    raw_code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: @challenge)

    pair = Mobile::AuthenticationService.exchange_authorization_code!(
      code: raw_code,
      code_verifier: @verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "Test iPhone"
    )

    assert pair[:access_token].start_with?("lm_at_")
    assert pair[:refresh_token].start_with?("lm_rt_")
    assert_equal "Test iPhone", pair[:device].name
    assert_nil MobileAuthorizationCode.first.attributes["code"]

    error = assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.exchange_authorization_code!(
        code: raw_code,
        code_verifier: @verifier,
        client_id: Mobile::AuthenticationService::CLIENT_ID,
        redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
        device_name: "Test iPhone"
      )
    end
    assert_equal "invalid_grant", error.code
  end

  test "rejects the wrong verifier without consuming the authorization code" do
    raw_code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: @challenge)

    assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.exchange_authorization_code!(
        code: raw_code,
        code_verifier: "x" * 43,
        client_id: Mobile::AuthenticationService::CLIENT_ID,
        redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
        device_name: "Test iPhone"
      )
    end

    assert_nil MobileAuthorizationCode.first.reload.used_at
  end

  test "rotates refresh tokens and revokes the device when one is reused" do
    pair = authorize_device
    rotated = Mobile::AuthenticationService.refresh!(
      refresh_token: pair[:refresh_token],
      client_id: Mobile::AuthenticationService::CLIENT_ID
    )
    assert_not_equal pair[:refresh_token], rotated[:refresh_token]

    error = assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.refresh!(
        refresh_token: pair[:refresh_token],
        client_id: Mobile::AuthenticationService::CLIENT_ID
      )
    end

    assert_equal "invalid_grant", error.code
    assert pair[:device].reload.revoked_at
    assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.authenticate_access_token(rotated[:access_token])
    end
  end

  test "issues only one usable web session ticket per device" do
    pair = authorize_device
    first = Mobile::AuthenticationService.issue_web_session_ticket!(device: pair[:device])
    second = Mobile::AuthenticationService.issue_web_session_ticket!(device: pair[:device])

    assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.consume_web_session_ticket!(first)
    end
    assert_equal @user, Mobile::AuthenticationService.consume_web_session_ticket!(second)
    assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.consume_web_session_ticket!(second)
    end
  end

  test "an inactive user cannot use an existing access token" do
    pair = authorize_device
    @user.update!(deactivated_at: Time.current)

    error = assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.authenticate_access_token(pair[:access_token])
    end
    assert_equal "invalid_token", error.code
  end

  private

  def authorize_device
    raw_code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: @challenge)
    Mobile::AuthenticationService.exchange_authorization_code!(
      code: raw_code,
      code_verifier: @verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "Test iPhone"
    )
  end
end
