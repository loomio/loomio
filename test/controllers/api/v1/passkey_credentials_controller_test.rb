require 'test_helper'
require 'webauthn/fake_client'

class Api::V1::PasskeyCredentialsControllerTest < ActionController::TestCase
  setup do
    @user = User.create!(
      email: "passkey-user@example.com",
      email_verified: true,
      name: "Passkey User"
    )
    @client = WebAuthn::FakeClient.new("http://test.host")
  end

  test "registration options assign a stable webauthn user id" do
    sign_in @user

    post :registration_options, format: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["challenge"].present?
    assert_equal @user.email, json.dig("user", "name")
    assert @user.reload.webauthn_id.present?
  end

  test "creates a passkey credential for the signed in user" do
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host")

    assert_difference "PasskeyCredential.count", 1 do
      post :create, params: { public_key_credential: credential }, format: :json
    end

    assert_response :success
    passkey = @user.passkey_credentials.last
    assert_equal credential["id"], passkey.external_id
    assert passkey.public_key.present?
    assert_equal ["internal"], passkey.transports
  end

  test "rejects a registration credential without the matching challenge" do
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host")
    session[PasskeyService::CHALLENGE_REGISTRATION] = "wrong-challenge"

    assert_no_difference "PasskeyCredential.count" do
      post :create, params: { public_key_credential: credential }, format: :json
    end

    assert_response :unprocessable_entity
  end

  test "authentication options require an account with a passkey" do
    post :authentication_options, params: { email: @user.email }, format: :json

    assert_response :not_found
  end

  test "authenticates with a registered passkey" do
    passkey = register_passkey
    sign_out

    post :authentication_options, params: { email: @user.email }, format: :json
    assert_response :success
    options = JSON.parse(response.body)

    assertion = @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      allow_credentials: [passkey.external_id]
    )

    assert_difference "Session.count", 1 do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @user.id, json["current_user_id"]
    assert_equal false, json["signed_in_via_login_code"]
    assert passkey.reload.last_used_at.present?
  end

  test "rejects passkey authentication with the wrong challenge" do
    passkey = register_passkey
    sign_out

    post :authentication_options, params: { email: @user.email }, format: :json
    options = JSON.parse(response.body)
    assertion = @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      allow_credentials: [passkey.external_id]
    )
    session[PasskeyService::CHALLENGE_AUTHENTICATION] = "wrong-challenge"

    assert_no_difference "Session.count" do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end

    assert_response :unauthorized
  end

  private

  def registration_options
    post :registration_options, format: :json
    assert_response :success
    JSON.parse(response.body)
  end

  def register_passkey
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host")
    post :create, params: { public_key_credential: credential }, format: :json
    assert_response :success
    @user.passkey_credentials.last
  end
end
