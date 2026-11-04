require 'test_helper'

class IdentityLinkingTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_EMAIL_LOGIN TURNSTILE_SECRET_KEY TERMS_URL OAUTH_APP_KEY OAUTH_APP_SECRET OAUTH_AUTH_URL OAUTH_TOKEN_URL OAUTH_PROFILE_URL OAUTH_SCOPE OAUTH_ATTR_UID OAUTH_ATTR_NAME OAUTH_ATTR_EMAIL].to_h { |key| [key, ENV.delete(key)] }
    ENV.update('OAUTH_APP_KEY' => 'client', 'OAUTH_APP_SECRET' => 'secret', 'OAUTH_AUTH_URL' => 'https://provider.example/authorize', 'OAUTH_TOKEN_URL' => 'https://provider.example/token', 'OAUTH_PROFILE_URL' => 'https://provider.example/profile', 'OAUTH_SCOPE' => 'openid email profile')
    @forgery_before = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    stub_request(:post, ENV['OAUTH_TOKEN_URL']).to_return(status: 200, body: { access_token: 'token' }.to_json, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, ENV['OAUTH_PROFILE_URL']).to_return(status: 200, body: { sub: 'linking', email: 'linking@example.com', name: 'Provider Person' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  teardown do
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    ActionController::Base.allow_forgery_protection = @forgery_before
  end

  test 'restoring a consumed linking cookie cannot move the identity to another account' do
    identity, saved_cookie = stage_linking
    authenticate(users(:member_loud))
    assert_equal users(:member_loud).id, identity.reload.user_id
    delete '/api/v1/sessions', headers: csrf_headers, as: :json
    authenticate(users(:alien_loud))

    cookies['_loomio'] = saved_cookie
    get '/api/v1/boot/site', as: :json

    assert_response :success
    assert_equal users(:alien_loud).id, response.parsed_body['current_user_id']
    assert_equal users(:member_loud).id, identity.reload.user_id
  end

  test 'logout clears pending linking state from the current browser' do
    identity, = stage_linking
    delete '/api/v1/sessions', headers: csrf_headers, as: :json
    assert_response :success
    authenticate(users(:alien_loud))
    assert_nil identity.reload.user_id
  end

  private

  def stage_linking
    authenticate(users(:member_loud))
    get '/oauth/oauth'
    state = Rack::Utils.parse_query(URI(response.location).query).fetch('state')
    get '/oauth/authorize', params: { code: 'code', state: state }
    assert_response :redirect
    identity = Identity.find_by!(identity_type: 'oauth', uid: 'linking')
    assert_nil identity.user_id
    [identity, cookies['_loomio']]
  end

  def authenticate(user)
    get '/dashboard'
    token = LoginToken.create!(user: user)
    post '/api/v1/sessions', params: { user: { email: user.email, code: token.code } }, headers: csrf_headers, as: :json
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
  end

  def csrf_headers
    { 'X-CSRF-TOKEN' => cookies['csrftoken'], 'Origin' => 'null' }
  end
end
