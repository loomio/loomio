require 'test_helper'
require 'webauthn/fake_client'

class Api::V1::PasskeyCredentialsControllerTest < ActionController::TestCase
  setup do
    @user = User.create!(email: "passkey-user@example.com", email_verified: true, name: "Passkey User")
    @authenticator = WebAuthn::FakeAuthenticator.new
    @client = WebAuthn::FakeClient.new("http://test.host", authenticator: @authenticator)
    @disable_local_login_before = ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN')
    @disable_email_login_before = ENV.delete('FEATURES_DISABLE_EMAIL_LOGIN')
    @canonical_host_before = ENV.delete('CANONICAL_HOST')
    @canonical_port_before = ENV.delete('CANONICAL_PORT')
    @force_ssl_before = ENV.delete('FORCE_SSL')
  end

  teardown do
    restore_env('FEATURES_DISABLE_LOCAL_LOGIN', @disable_local_login_before)
    restore_env('FEATURES_DISABLE_EMAIL_LOGIN', @disable_email_login_before)
    restore_env('CANONICAL_HOST', @canonical_host_before)
    restore_env('CANONICAL_PORT', @canonical_port_before)
    restore_env('FORCE_SSL', @force_ssl_before)
  end

  test "registration creates a discoverable passkey for the signed in user" do
    sign_in @user
    options = registration_options
    assert_equal "required", options.dig("authenticatorSelection", "residentKey")
    assert_equal "required", options.dig("authenticatorSelection", "userVerification")
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: true)

    assert_difference "PasskeyCredential.count", 1 do
      post :create, params: { name: "Work laptop", public_key_credential: credential }, format: :json
    end

    assert_response :created
    passkey = @user.passkey_credentials.last
    assert_equal "Work laptop", passkey.name
    assert_equal credential["id"], passkey.external_id
    assert @user.reload.webauthn_id.present?
  end

  test "registration accepts a valid CSRF token when the browser sends a null origin" do
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: true)
    csrf_token = @controller.send(:form_authenticity_token)
    cookies['csrftoken'] = csrf_token
    @request.headers['X-CSRF-TOKEN'] = csrf_token
    @request.headers['Origin'] = 'null'

    with_forgery_protection do
      assert_difference "PasskeyCredential.count", 1 do
        post :create, params: { name: "Private browser", public_key_credential: credential }, format: :json
      end
    end

    assert_response :created
  end

  test "registration accepts public key fields returned by browser credential serialization" do
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: true)
    credential["response"]["publicKey"] = "browser-provided-public-key"
    credential["response"]["publicKeyAlgorithm"] = -7

    assert_difference "PasskeyCredential.count", 1 do
      post :create, params: { name: "Browser passkey", public_key_credential: credential }, format: :json
    end

    assert_response :created
  end

  test "registration rejects missing CSRF tokens" do
    sign_in @user

    with_forgery_protection do
      assert_raises(ActionController::InvalidAuthenticityToken) do
        post :create, params: { public_key_credential: {} }, format: :json
      end
    end
  end

  test "registration rejects arbitrary matching CSRF cookie and header values" do
    sign_in @user
    cookies['csrftoken'] = 'attacker-controlled'
    @request.headers['X-CSRF-TOKEN'] = 'attacker-controlled'
    @request.headers['Origin'] = 'null'

    with_forgery_protection do
      assert_raises(ActionController::InvalidAuthenticityToken) do
        post :create, params: { public_key_credential: {} }, format: :json
      end
    end
  end

  test "options bind passkeys to the configured canonical host and origin" do
    ENV['CANONICAL_HOST'] = 'community.example.org'
    ENV['CANONICAL_PORT'] = '8443'
    ENV['FORCE_SSL'] = '1'
    canonical_client = WebAuthn::FakeClient.new('https://community.example.org:8443')
    sign_in @user

    options = registration_options
    credential = canonical_client.create(
      challenge: options['challenge'],
      rp_id: 'community.example.org',
      user_verified: true
    )

    assert_difference "PasskeyCredential.count", 1 do
      post :create, params: { name: "Canonical passkey", public_key_credential: credential }, format: :json
    end
    assert_response :created
  end

  test "authentication options do not accept or reveal an email address" do
    post :authentication_options, params: { email: @user.email }, format: :json

    assert_response :success
    options = JSON.parse(response.body)
    assert_empty options["allowCredentials"]
    assert_equal "required", options["userVerification"]
    assert session[PasskeyService::CHALLENGE_AUTHENTICATION].present?
  end

  test "registration rejects a credential without user verification" do
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: false)

    assert_no_difference "PasskeyCredential.count" do
      post :create, params: { name: "Unverified", public_key_credential: credential }, format: :json
    end
    assert_response :unprocessable_entity
  end

  test "registration requires a recently created session" do
    sign_in @user
    Current.session.update_column(:created_at, PasskeyService::RECENT_AUTHENTICATION_TTL.ago - 1.minute)

    post :registration_options, format: :json

    assert_response :forbidden
    assert_equal [I18n.t('auth_form.passkey_recent_authentication_required')], JSON.parse(response.body).dig('errors', 'passkey')
  end

  test "removes only the signed in user's passkey after recent authentication" do
    passkey = register_passkey
    other_user = User.create!(email: "other-passkey@example.com", email_verified: true)
    other_user.update!(webauthn_id: WebAuthn.generate_user_id)
    other_passkey = other_user.passkey_credentials.create!(
      external_id: "other-credential",
      public_key: "other-public-key",
      user_handle: other_user.webauthn_id,
      sign_count: 0,
      name: "Other passkey"
    )

    assert_no_difference "PasskeyCredential.count" do
      delete :destroy, params: { id: other_passkey.id }, format: :json
    end
    assert_response :not_found

    assert_difference "PasskeyCredential.count", -1 do
      delete :destroy, params: { id: passkey.id }, format: :json
    end
    assert_response :success
  end

  test "authenticates from the discoverable credential returned by the authenticator" do
    passkey = register_passkey
    sign_out
    post :authentication_options, format: :json
    options = JSON.parse(response.body)
    assertion = @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      user_verified: true,
      user_handle: WebAuthn::Encoder.new(:base64url).decode(@user.webauthn_id),
      allow_credentials: [passkey.external_id]
    )

    assert_difference "Session.count", 1 do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @user.id, json["current_user_id"]
    assert_equal true, json.dig("users", 0, "has_passkey")
    assert passkey.reload.last_used_at.present?
  end

  test "an unknown but valid credential returns the generic authentication failure" do
    unknown_credential = @client.create(rp_id: "test.host", user_verified: true)

    post :authentication_options, format: :json
    options = JSON.parse(response.body)
    assertion = @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      user_verified: true,
      allow_credentials: [unknown_credential["id"]]
    )

    assert_no_difference "Session.count" do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end

    assert_response :unauthorized
    assert_equal [I18n.t('auth_form.passkey_authentication_failed')], JSON.parse(response.body).dig('errors', 'passkey')
  end

  test "a challenge cannot be reused" do
    passkey = register_passkey
    sign_out
    post :authentication_options, format: :json
    options = JSON.parse(response.body)
    assertion = @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      user_verified: true,
      user_handle: WebAuthn::Encoder.new(:base64url).decode(@user.webauthn_id),
      allow_credentials: [passkey.external_id]
    )

    post :authenticate, params: { public_key_credential: assertion }, format: :json
    assert_response :success
    sign_out

    assert_no_difference "Session.count" do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end
    assert_response :unauthorized
  end

  test "a consumed challenge cannot be replayed by restoring its saved cookie state" do
    passkey = register_passkey
    sign_out
    post :authentication_options, format: :json
    options = JSON.parse(response.body)
    saved_challenge = session[PasskeyService::CHALLENGE_AUTHENTICATION].deep_dup
    assertion = authentication_assertion(passkey, options)

    post :authenticate, params: { public_key_credential: assertion }, format: :json
    assert_response :success
    sign_out
    session[PasskeyService::CHALLENGE_AUTHENTICATION] = saved_challenge

    assert_no_difference "Session.count" do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end
    assert_response :unauthorized
  end

  test "issuing a new challenge invalidates the previous challenge" do
    post :authentication_options, format: :json
    first = session[PasskeyService::CHALLENGE_AUTHENTICATION].deep_dup
    post :authentication_options, format: :json

    assert_not_equal first[:challenge_id], session[PasskeyService::CHALLENGE_AUTHENTICATION][:challenge_id]
    assert_not PasskeyChallenge.exists?(first[:challenge_id])
  end

  test "authentication rejects the wrong origin, relying party, signature, verification, and user handle" do
    passkey = register_passkey
    sign_out

    invalid_assertions = [
      # Sign the wrong RP hash with the registered key, leaving the origin valid.
      ->(options) { @authenticator.stub(:hashed, Digest::SHA256.digest('evil.test')) { authentication_assertion(passkey, options) } },
      ->(options) { WebAuthn::FakeClient.new("http://evil.test", authenticator: @authenticator).get(challenge: options["challenge"], rp_id: "test.host", user_verified: true, user_handle: decoded_user_handle, allow_credentials: [passkey.external_id]) },
      ->(options) { authentication_assertion(passkey, options).tap { |value| value["response"]["signature"] = WebAuthn::Encoder.new(:base64url).encode("altered") } },
      ->(options) { @client.get(challenge: options["challenge"], rp_id: "test.host", user_verified: false, user_handle: decoded_user_handle, allow_credentials: [passkey.external_id]) },
      ->(options) { @client.get(challenge: options["challenge"], rp_id: "test.host", user_verified: true, user_handle: "wrong-handle", allow_credentials: [passkey.external_id]) }
    ]

    invalid_assertions.each do |build_assertion|
      post :authentication_options, format: :json
      assertion = build_assertion.call(JSON.parse(response.body))
      assert_no_difference "Session.count" do
        post :authenticate, params: { public_key_credential: assertion }, format: :json
      end
      assert_response :unauthorized
    end
  end

  test "registration rejects a credential for the wrong relying party" do
    sign_in @user
    options = registration_options
    wrong_rp_client = WebAuthn::FakeClient.new("http://test.host")
    credential = wrong_rp_client.create(challenge: options["challenge"], rp_id: "evil.test", user_verified: true)

    assert_no_difference "PasskeyCredential.count" do
      post :create, params: { name: "Wrong site", public_key_credential: credential }, format: :json
    end
    assert_response :unprocessable_entity
  end

  test "authentication rejects a credential whose owner is inactive" do
    passkey = register_passkey
    @user.update!(deactivated_at: Time.current)
    sign_out
    post :authentication_options, format: :json

    assert_no_difference "Session.count" do
      post :authenticate, params: { public_key_credential: authentication_assertion(passkey, JSON.parse(response.body)) }, format: :json
    end
    assert_response :unauthorized
  end

  test "authentication permits zero and increasing counters but rejects unchanged or regressing nonzero counters" do
    passkey = register_passkey
    sign_out
    post :authentication_options, format: :json
    post :authenticate, params: { public_key_credential: authentication_assertion(passkey, JSON.parse(response.body), sign_count: 0) }, format: :json
    assert_response :success
    assert_equal 0, passkey.reload.sign_count

    sign_out
    post :authentication_options, format: :json
    post :authenticate, params: { public_key_credential: authentication_assertion(passkey, JSON.parse(response.body), sign_count: 5) }, format: :json
    assert_response :success
    assert_equal 5, passkey.reload.sign_count

    [5, 4].each do |invalid_count|
      sign_out
      post :authentication_options, format: :json
      assert_no_difference "Session.count" do
        post :authenticate, params: { public_key_credential: authentication_assertion(passkey, JSON.parse(response.body), sign_count: invalid_count) }, format: :json
      end
      assert_response :unauthorized
    end

    assert_equal 5, passkey.reload.sign_count
  end

  test "authentication and registration reject missing credential parameters without changing state" do
    assert_no_difference "Session.count" do
      post :authentication_options, format: :json
      post :authenticate, params: {}, format: :json
    end
    assert_response :bad_request

    sign_in @user
    registration_options
    assert_no_difference "PasskeyCredential.count" do
      post :create, params: {}, format: :json
    end
    assert_response :bad_request
  end

  test "registration rejects oversized names without persistence" do
    sign_in @user
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: true)

    assert_no_difference "PasskeyCredential.count" do
      post :create, params: { name: "x" * 101, public_key_credential: credential }, format: :json
    end
    assert_response :unprocessable_entity
  end

  test "create and destroy independently require recent authentication" do
    passkey = register_passkey
    options = registration_options
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: true)
    Current.session.update_column(:created_at, PasskeyService::RECENT_AUTHENTICATION_TTL.ago - 1.minute)

    assert_no_difference "PasskeyCredential.count" do
      post :create, params: { name: "Stale", public_key_credential: credential }, format: :json
    end
    assert_response :forbidden

    assert_no_difference "PasskeyCredential.count" do
      delete :destroy, params: { id: passkey.id }, format: :json
    end
    assert_response :forbidden
  end

  test "restricted access cannot list or mutate passkeys" do
    passkey = register_passkey
    sign_out
    @user.update_columns(unsubscribe_token: "passkey-unsubscribe-test")

    get :index, params: { unsubscribe_token: @user.unsubscribe_token }, format: :json
    assert_response :unauthorized
    delete :destroy, params: { id: passkey.id, unsubscribe_token: @user.unsubscribe_token }, format: :json
    assert_response :unauthorized
    assert PasskeyCredential.exists?(passkey.id)
  end

  test "index returns only safe metadata for the current user's credentials" do
    passkey = register_passkey
    other_user = User.create!(email: "passkey-list-other@example.com", email_verified: true, name: "Other")
    other_user.update!(webauthn_id: WebAuthn.generate_user_id)
    other = other_user.passkey_credentials.create!(external_id: "private-other", public_key: "secret-public-key", user_handle: other_user.webauthn_id, sign_count: 0, name: "Other key")

    get :index, format: :json

    assert_response :success
    body = response.body
    assert_includes body, passkey.name
    assert_not_includes body, other.name
    assert_not_includes body, passkey.public_key
    assert_not_includes body, passkey.user_handle
  end

  test "an expired challenge cannot authenticate" do
    passkey = register_passkey
    sign_out
    post :authentication_options, format: :json
    options = JSON.parse(response.body)
    assertion = @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      user_verified: true,
      user_handle: WebAuthn::Encoder.new(:base64url).decode(@user.webauthn_id),
      allow_credentials: [passkey.external_id]
    )
    PasskeyChallenge.find(session[PasskeyService::CHALLENGE_AUTHENTICATION][:challenge_id]).update!(expires_at: 1.minute.ago)

    assert_no_difference "Session.count" do
      post :authenticate, params: { public_key_credential: assertion }, format: :json
    end
    assert_response :unauthorized
  end

  test "SSO-only mode rejects passkey registration and authentication" do
    ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = '1'
    sign_in @user

    post :registration_options, format: :json
    assert_response :forbidden

    sign_out
    post :authentication_options, format: :json
    assert_response :forbidden
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
    credential = @client.create(challenge: options["challenge"], rp_id: "test.host", user_verified: true)
    post :create, params: { name: "Test passkey", public_key_credential: credential }, format: :json
    assert_response :created
    @user.passkey_credentials.last
  end

  def decoded_user_handle
    WebAuthn::Encoder.new(:base64url).decode(@user.webauthn_id)
  end

  def authentication_assertion(passkey, options, sign_count: nil)
    @client.get(
      challenge: options["challenge"],
      rp_id: "test.host",
      user_verified: true,
      user_handle: decoded_user_handle,
      allow_credentials: [passkey.external_id],
      sign_count: sign_count
    )
  end

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end

  def with_forgery_protection
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end
end
