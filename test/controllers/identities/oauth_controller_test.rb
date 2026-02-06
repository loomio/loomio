require 'test_helper'
require 'webmock/minitest'

class Identities::OauthControllerTest < ActionController::TestCase
  setup do
    # Set required ENV variables for OAuth
    @saved_env = {}
    %w[OAUTH_AUTH_URL OAUTH_TOKEN_URL OAUTH_PROFILE_URL OAUTH_SCOPE
       OAUTH_ATTR_UID OAUTH_ATTR_NAME OAUTH_ATTR_EMAIL OAUTH_APP_KEY OAUTH_APP_SECRET
       LOOMIO_SSO_FORCE_USER_ATTRS].each do |key|
      @saved_env[key] = ENV[key]
    end

    ENV['OAUTH_AUTH_URL'] = 'https://oauth.provider.com/authorize'
    ENV['OAUTH_TOKEN_URL'] = 'https://oauth.provider.com/token'
    ENV['OAUTH_PROFILE_URL'] = 'https://oauth.provider.com/userinfo'
    ENV['OAUTH_SCOPE'] = 'openid profile email'
    ENV['OAUTH_ATTR_UID'] = 'sub'
    ENV['OAUTH_ATTR_NAME'] = 'name'
    ENV['OAUTH_ATTR_EMAIL'] = 'email'
    ENV['OAUTH_APP_KEY'] = 'mock_client_id'
    ENV['OAUTH_APP_SECRET'] = 'mock_client_secret'

    stub_request(:post, 'https://oauth.provider.com/token')
      .to_return(
        status: 200,
        body: { access_token: 'mock_access_token' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, 'https://oauth.provider.com/userinfo')
      .to_return(
        status: 200,
        body: {
          sub: 'oauth_user_123',
          name: 'OAuth User',
          email: 'oauth@example.com'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    @saved_env.each { |key, val| ENV[key] = val }
    WebMock.reset!
  end

  # OAuth redirect tests
  test "redirects to OAuth provider with correct parameters" do
    get :oauth, params: { back_to: '/some/path' }
    assert_equal '/some/path', session[:back_to]
    assert_match(/https:\/\/oauth\.provider\.com\/authorize/, response.location)
    assert_includes response.location, 'client_id=mock_client_id'
    assert_includes response.location, 'scope=openid+profile+email'
  end

  test "stores referrer as back_to when no back_to param" do
    request.env['HTTP_REFERER'] = 'http://test.host/previous/page'
    get :oauth
    assert_equal 'http://test.host/previous/page', session[:back_to]
  end

  # Create tests - user does not exist
  test "creates user and signs in when user does not exist" do
    session[:back_to] = '/dashboard'

    assert_difference ['Identity.where(identity_type: "oauth").count', 'User.count'], 1 do
      get :create, params: { code: 'authorization_code_123' }
    end

    identity = Identity.where(identity_type: 'oauth').last
    assert_equal 'oauth_user_123', identity.uid
    assert_equal 'oauth@example.com', identity.email
    assert identity.user.present?
    assert_equal 'oauth@example.com', identity.user.email
    assert_equal 'OAuth User', identity.user.name
    assert_equal true, identity.user.email_verified

    assert_equal identity.user, @controller.current_user
    assert_redirected_to '/dashboard'
    assert_equal I18n.t('devise.sessions.signed_in'), flash[:notice]
  end

  # Create tests - user with same email exists
  test "attaches identity to existing user and signs in" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'oauth@example.com', username: "oauthex#{hex}", email_verified: true)
    session[:back_to] = '/dashboard'

    assert_difference 'Identity.where(identity_type: "oauth").count', 1 do
      assert_no_difference 'User.count' do
        get :create, params: { code: 'authorization_code_123' }
      end
    end

    identity = Identity.where(identity_type: 'oauth').last
    assert_equal existing_user, identity.user
    assert_equal 1, existing_user.reload.identities.count

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  test "does not overwrite user name by default" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'oauth@example.com', username: "oauthex#{hex}", email_verified: true)
    get :create, params: { code: 'authorization_code_123' }
    assert_equal 'Original Name', existing_user.reload.name
  end

  # Force user attrs
  test "overwrites name when sso_force_user_attrs is true" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'oauth@example.com', username: "oauthex#{hex}", email_verified: true)
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = 'true'

    get :create, params: { code: 'authorization_code_123' }

    existing_user.reload
    assert_equal 'OAuth User', existing_user.name
    assert_equal 'oauth@example.com', existing_user.email
    assert_equal existing_user, @controller.current_user
  end

  # Unverified user
  test "verifies email for unverified user with same email" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'oauth@example.com', username: "oauthex#{hex}", email_verified: false)
    session[:back_to] = '/dashboard'

    assert_difference 'Identity.where(identity_type: "oauth").count', 1 do
      assert_no_difference 'User.count' do
        get :create, params: { code: 'authorization_code_123' }
      end
    end

    identity = Identity.where(identity_type: 'oauth').last
    assert_equal existing_user, identity.user
    assert_equal true, existing_user.reload.email_verified

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  # Identity already exists with same uid
  test "updates identity and signs in existing user when uid matches" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original', email: "existing#{hex}@example.com", username: "oauthex#{hex}", email_verified: true)
    existing_identity = Identity.create!(
      identity_type: 'oauth',
      uid: 'oauth_user_123',
      email: 'old_email@example.com',
      access_token: 'old_token',
      user: existing_user
    )
    session[:back_to] = '/dashboard'

    assert_no_difference ['Identity.where(identity_type: "oauth").count', 'User.count'] do
      get :create, params: { code: 'authorization_code_123' }
    end

    existing_identity.reload
    assert_equal 'oauth_user_123', existing_identity.uid
    assert_equal 'oauth@example.com', existing_identity.email
    assert_equal 'mock_access_token', existing_identity.access_token
    assert_equal existing_user, existing_identity.user

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  # uid with different email, force attrs
  test "updates email from SSO when uid matches and force attrs enabled" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'old_email@example.com', username: "oauthex#{hex}", email_verified: true)
    existing_identity = Identity.create!(
      identity_type: 'oauth',
      uid: 'oauth_user_123',
      email: 'old_email@example.com',
      name: 'Original Name',
      access_token: 'old_token',
      user: existing_user
    )
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = 'true'
    session[:back_to] = '/dashboard'

    get :create, params: { code: 'authorization_code_123' }

    existing_identity.reload
    assert_equal 'oauth@example.com', existing_identity.email
    assert_equal 'OAuth User', existing_identity.name

    existing_user.reload
    assert_equal 'oauth@example.com', existing_user.email
    assert_equal 'OAuth User', existing_user.name

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  # Already signed in
  test "creates pending identity when user already signed in" do
    hex = SecureRandom.hex(4)
    current_user = User.create!(name: "signed#{hex}", email: "signed#{hex}@example.com", username: "signed#{hex}", email_verified: true)
    sign_in current_user
    session[:back_to] = '/settings'

    assert_difference 'Identity.where(identity_type: "oauth").count', 1 do
      assert_no_difference -> { current_user.identities.count } do
        get :create, params: { code: 'authorization_code_123' }
      end
    end

    identity = Identity.where(identity_type: 'oauth').last
    assert_nil identity.user_id
    assert_equal 'oauth@example.com', identity.email

    assert_equal identity.id, session[:pending_identity_id]
    assert_redirected_to '/settings'
    assert_equal I18n.t('auth.switching_accounts'), flash[:notice]
  end

  # Auth failure - user cancels
  test "returns to dashboard with error when user cancels" do
    session[:back_to] = '/dashboard'
    get :create, params: { error: 'access_denied' }
    assert_redirected_to '/dashboard'
    assert_equal I18n.t('auth.oauth_cancelled'), flash[:error]
  end

  # Auth failure - token not returned
  test "returns 401 when access token fails" do
    stub_request(:post, 'https://oauth.provider.com/token')
      .to_return(
        status: 400,
        body: { error: 'invalid_grant' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    get :create, params: { code: 'invalid_code' }, format: :json
    assert_response 401
    json = JSON.parse(response.body)
    assert_equal 'OAuth authorization failed', json['error']
  end

  # Auth failure - profile fetch fails
  test "returns 401 when profile fetch fails" do
    stub_request(:get, 'https://oauth.provider.com/userinfo')
      .to_return(
        status: 200,
        body: { error: 'invalid_token' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    get :create, params: { code: 'valid_code' }, format: :json
    assert_response 401
    json = JSON.parse(response.body)
    assert_equal 'Could not fetch user profile from OAuth provider', json['error']
  end

  # Fallback redirect
  test "redirects to dashboard when no back_to is set" do
    get :create, params: { code: 'authorization_code_123' }
    assert_redirected_to dashboard_path
  end

  # Destroy tests
  test "destroys identity connection" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "oauser#{hex}", email: "oauser#{hex}@example.com", username: "oauser#{hex}", email_verified: true)
    identity = Identity.create!(identity_type: 'oauth', uid: 'oauth_user_123', email: 'oauth@example.com', access_token: 'token', user: user)
    sign_in user
    request.env['HTTP_REFERER'] = 'http://test.host/settings'

    assert_difference -> { user.identities.count }, -1 do
      get :destroy
    end

    assert_nil Identity.find_by(id: identity.id, identity_type: 'oauth')
    assert_redirected_to 'http://test.host/settings'
  end

  test "destroy redirects to root when no referrer" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "oauser#{hex}", email: "oauser#{hex}@example.com", username: "oauser#{hex}", email_verified: true)
    Identity.create!(identity_type: 'oauth', uid: 'oauth_user_123', email: 'oauth@example.com', access_token: 'token', user: user)
    sign_in user
    get :destroy
    assert_redirected_to root_path
  end

  test "destroy returns error when not connected to oauth" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "oauser#{hex}", email: "oauser#{hex}@example.com", username: "oauser#{hex}", email_verified: true)
    sign_in user
    get :destroy, format: :json
    assert_response 500
    json = JSON.parse(response.body)
    assert json['error'].present?
  end
end
