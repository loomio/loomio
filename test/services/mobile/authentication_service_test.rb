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
    freeze_time
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
    token = Mobile::AuthenticationService.authenticate_access_token(pair[:access_token])
    assert_equal pair[:device], token.mobile_device
    assert_equal @user, token.mobile_device.user
    assert_equal Mobile::AuthenticationService::SCOPES, token.scopes
    assert_equal Mobile::AuthenticationService::ACCESS_TOKEN_TTL.from_now, token.expires_at
    refresh = pair[:device].mobile_refresh_tokens.sole
    assert_equal Mobile::AuthenticationService::REFRESH_IDLE_TTL.from_now, refresh.idle_expires_at
    assert_equal Mobile::AuthenticationService::REFRESH_ABSOLUTE_TTL.from_now, refresh.expires_at

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

  test "rejects an invalid client callback or verifier without consuming the authorization code" do
    [
      { client_id: "another-client", code: "invalid_client", status: :unauthorized },
      { redirect_uri: "org.loomio.mobile:/another-callback", code: "invalid_grant", status: :unauthorized },
      { verifier: "v" * 42, code: "invalid_request", status: :bad_request },
      { verifier: "v" * 129, code: "invalid_request", status: :bad_request },
      { verifier: "!" * 43, code: "invalid_request", status: :bad_request }
    ].each do |invalid|
      verifier = invalid.fetch(:verifier, @verifier)
      challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
      raw_code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: challenge)
      authorization = MobileAuthorizationCode.order(:id).last

      assert_no_difference ["MobileDevice.count", "MobileAccessToken.count", "MobileRefreshToken.count"] do
        error = assert_raises(Mobile::AuthenticationService::Error) do
          Mobile::AuthenticationService.exchange_authorization_code!(
            code: raw_code,
            code_verifier: verifier,
            client_id: invalid.fetch(:client_id, Mobile::AuthenticationService::CLIENT_ID),
            redirect_uri: invalid.fetch(:redirect_uri, Mobile::AuthenticationService::REDIRECT_URI),
            device_name: "Rejected iPhone"
          )
        end
        assert_equal invalid.fetch(:code), error.code
        assert_equal invalid.fetch(:status), error.status
      end
      assert_nil authorization.reload.used_at
    end
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

  test "rejects an unknown expired or wrong-client refresh without rotating credentials" do
    freeze_time
    pair = authorize_device
    refresh = pair[:device].mobile_refresh_tokens.sole

    [
      ["lm_rt_unknown", Mobile::AuthenticationService::CLIENT_ID, "invalid_grant"],
      [pair[:refresh_token], "another-client", "invalid_client"]
    ].each do |raw_token, client_id, code|
      assert_no_difference ["MobileAccessToken.count", "MobileRefreshToken.count"] do
        error = assert_raises(Mobile::AuthenticationService::Error) do
          Mobile::AuthenticationService.refresh!(refresh_token: raw_token, client_id: client_id)
        end
        assert_equal code, error.code
        assert_equal :unauthorized, error.status
      end
      assert_nil refresh.reload.consumed_at
    end

    travel_to refresh.idle_expires_at do
      assert_no_difference ["MobileAccessToken.count", "MobileRefreshToken.count"] do
        error = assert_raises(Mobile::AuthenticationService::Error) do
          Mobile::AuthenticationService.refresh!(refresh_token: pair[:refresh_token], client_id: Mobile::AuthenticationService::CLIENT_ID)
        end
        assert_equal "invalid_grant", error.code
      end
      assert_nil refresh.reload.consumed_at
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

  test "a revoked device cannot issue a web session ticket" do
    pair = authorize_device
    pair[:device].revoke!

    assert_no_difference "MobileWebSessionTicket.count" do
      error = assert_raises(Mobile::AuthenticationService::Error) do
        Mobile::AuthenticationService.issue_web_session_ticket!(device: pair[:device])
      end
      assert_equal "device_revoked", error.code
      assert_equal :unauthorized, error.status
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
