require 'test_helper'

class SsoLoginTokenTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_EMAIL_LOGIN TURNSTILE_SECRET_KEY TERMS_URL LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS].to_h { |key| [key, ENV.delete(key)] }
    ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = '1'
    @forgery_before = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    ActionController::Base.allow_forgery_protection = @forgery_before
  end

  test 'an admin sign-in link works in a separate browser on an SSO-only site' do
    sign_in_with_link(users(:admin))
    assert_difference 'LoginToken.count', 1 do
      post login_as_admin_user_path(users(:user)), headers: csrf_headers
    end
    assert_response :success
    token = users(:user).login_tokens.sole
    assert_select 'a[href=?]', login_token_url(token.token)

    browser = open_session
    browser.get login_token_path(token.token)
    browser.follow_redirect!
    assert_difference 'Session.count', 1 do
      browser.post '/api/v1/sessions', headers: csrf_headers(browser), as: :json
    end
    browser.assert_response :success
    assert_equal users(:user).id, browser.response.parsed_body['current_user_id']
    assert token.reload.used

    assert_difference 'Session.count', -1 do
      browser.delete '/api/v1/sessions', headers: csrf_headers(browser), as: :json
    end
    browser.assert_response :success

    browser.get login_token_path(token.token)
    browser.follow_redirect!
    assert_no_difference 'Session.count' do
      browser.post '/api/v1/sessions', headers: csrf_headers(browser), as: :json
    end
    browser.assert_response :forbidden
  end

  test 'signed-out users, members, and group coordinators cannot generate admin sign-in links' do
    get '/dashboard'
    assert_no_difference 'LoginToken.count' do
      post login_as_admin_user_path(users(:user)), headers: csrf_headers
    end
    assert_redirected_to dashboard_path

    [users(:member), users(:alien), users(:former_member_loud)].each do |user|
      refute user.is_admin?
      sign_in_with_link(user)
      assert_no_difference 'LoginToken.count' do
        post login_as_admin_user_path(users(:user)), headers: csrf_headers
      end
      assert_redirected_to dashboard_path
      delete '/api/v1/sessions', headers: csrf_headers, as: :json
      assert_response :success
    end
  end

  test 'signed-out and signed-in users cannot request local sign-in links or register accounts' do
    [nil, users(:member)].each do |user|
      user ? sign_in_with_link(user) : get('/dashboard')
      assert_no_difference ['LoginToken.count', 'User.count'] do
        post '/api/v1/login_tokens', params: { email: users(:user).email }, headers: csrf_headers, as: :json
        assert_response :forbidden
        post '/api/v1/registrations', params: { user: { email: 'sso-native@example.com' } }, headers: csrf_headers, as: :json
        assert_response :forbidden
      end
    end
  end

  test 'admin link creation and token sign-in require CSRF protection' do
    sign_in_with_link(users(:admin))
    assert_no_difference 'LoginToken.count' do
      post login_as_admin_user_path(users(:user))
    end
    assert_response :unprocessable_entity

    token = LoginToken.create!(user: users(:user))
    browser = open_session
    browser.get login_token_path(token.token)
    browser.follow_redirect!
    assert_no_difference 'Session.count' do
      browser.post '/api/v1/sessions', as: :json
    end
    browser.assert_response :unprocessable_entity
    refute token.reload.used
  end

  test 'an existing link can complete an incomplete account on an SSO-only site' do
    ENV['TERMS_URL'] = 'https://example.com/terms'
    user = User.create!(email: 'sso-link-completion@example.com', email_verified: true)
    token = LoginToken.create!(user: user)
    get login_token_path(token.token)
    follow_redirect!

    assert_no_difference 'Session.count' do
      post '/api/v1/sessions', headers: csrf_headers, as: :json
    end
    assert_response :success
    assert response.parsed_body['incomplete']
    assert token.reload.used

    browser = open_session
    browser.get login_token_path(token.token)
    browser.follow_redirect!
    assert_no_difference ['Session.count', 'AccountCompletionProof.count'] do
      browser.post '/api/v1/sessions', headers: csrf_headers(browser), as: :json
    end
    browser.assert_response :forbidden

    assert_difference 'Session.count', 1 do
      post '/api/v1/registrations/complete', params: { user: { name: 'Completed Person', legal_accepted: true } }, headers: csrf_headers, as: :json
    end
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
    assert token.reload.used
    assert_empty AccountCompletionProof.where(user: user)
  end

  private

  def csrf_headers(browser = self)
    { 'X-CSRF-TOKEN' => browser.cookies['csrftoken'], 'Origin' => 'null' }
  end

  def sign_in_with_link(user)
    token = LoginToken.create!(user: user)
    get login_token_path(token.token)
    follow_redirect!
    post '/api/v1/sessions', headers: csrf_headers, as: :json
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
  end
end
