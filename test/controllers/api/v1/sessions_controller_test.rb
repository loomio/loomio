require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  setup do
    @original_turnstile_secret = ENV['TURNSTILE_SECRET_KEY']
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_turnstile_secret
  end

  test "turnstile is not required when TURNSTILE_SECRET_KEY is unset" do
    ENV['TURNSTILE_SECRET_KEY'] = nil
    user = User.create!(email: "nocaptcha@example.com", email_verified: true, password: "s3curepassword123")
    post :create, params: { user: { email: user.email, password: "s3curepassword123" } }
    assert_response :success
  end

  test "turnstile required: rejects password sign-in without token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    user = User.create!(email: "captcha1@example.com", email_verified: true, password: "s3curepassword123")
    post :create, params: { user: { email: user.email, password: "s3curepassword123" } }
    assert_response :forbidden
    assert_equal ['turnstile'], JSON.parse(response.body)['errors'].keys
  end

  test "turnstile required: accepts password sign-in with valid token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    user = User.create!(email: "captcha2@example.com", email_verified: true, password: "s3curepassword123")
    post :create, params: { user: { email: user.email, password: "s3curepassword123", turnstile_token: "cf-ok" } }
    assert_response :success
  end

  test "turnstile required: rejects password sign-in when Cloudflare says no" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: false }.to_json, headers: { 'Content-Type' => 'application/json' })
    user = User.create!(email: "captcha3@example.com", email_verified: true, password: "s3curepassword123")
    post :create, params: { user: { email: user.email, password: "s3curepassword123", turnstile_token: "cf-bad" } }
    assert_response :forbidden
  end

  test "turnstile is skipped on pending_login_token (email link)" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    # If Turnstile were consulted we'd need to stub it; by asserting success without a stub
    # we prove the email-link path short-circuits the challenge.
    user = User.create!(email: "emailink@example.com", email_verified: true)
    token = LoginToken.create!(user: user)
    session[:pending_login_token] = token.token
    post :create
    assert_response :success
  end

  test "turnstile is skipped only for a valid login code" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    user = User.create!(email: "emailcode@example.com", email_verified: true)
    token = LoginToken.create!(user: user)

    post :create, params: { user: { email: user.email, code: token.code } }
    assert_response :success
  end

  test "turnstile is required for an invalid login code" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    user = User.create!(email: "bademailcode@example.com", email_verified: true)
    token = LoginToken.create!(user: user)

    post :create, params: { user: { email: user.email, code: token.code + 1 } }
    assert_response :forbidden
  end

  test "invalid login code attempts are counted before turnstile" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    user = User.create!(email: "countbadcode@example.com", email_verified: true)
    token = LoginToken.create!(user: user)

    post :create, params: { user: { email: user.email, code: token.code + 1 } }

    assert_response :forbidden
    assert_equal 1, token.reload.failed_attempts
  end

  test "invalid login code attempts burn the token at the limit" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    user = User.create!(email: "burnbadcode@example.com", email_verified: true)
    token = LoginToken.create!(user: user, failed_attempts: LoginToken::MAX_FAILED_CODE_ATTEMPTS - 1)

    post :create, params: { user: { email: user.email, code: token.code + 1 } }

    assert_response :forbidden
    assert token.reload.used
    assert_not token.useable?
  end

  test "signs in with password" do
    user = User.create!(
      email: "sessionsuser@example.com",
      email_verified: true,
      password: "s3curepassword123"
    )
    
    post :create, params: { user: { email: "sessionsuser@example.com", password: "s3curepassword123" } }
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "does not sign in a blank password" do
    User.create!(email: "sessionsuser2@example.com", email_verified: true)
    
    post :create, params: { user: { email: "sessionsuser2@example.com", password: "" } }
    assert_response :unauthorized
  end

  test "returns account locked failure for locked accounts" do
    user = User.create!(email: "lockedlogin@example.com", email_verified: true, password: "s3curepassword123")
    user.update!(locked_at: Time.current)

    post :create, params: { user: { email: user.email, password: "wrongpassword" } }

    assert_response :unauthorized
    assert_equal [I18n.t('auth_form.account_locked')], JSON.parse(response.body).dig('errors', 'password')
  end

  test "returns email not found when password login account does not exist" do
    post :create, params: { user: { email: "missinglogin@example.com", password: "wrongpassword" } }

    assert_response :unauthorized
    assert_equal [I18n.t('auth_form.email_not_found')], JSON.parse(response.body).dig('errors', 'email')
  end

  test "returns invalid password when password does not match" do
    user = User.create!(email: "wrongpasswordlogin@example.com", email_verified: true, password: "s3curepassword123")

    post :create, params: { user: { email: user.email, password: "wrongpassword" } }

    assert_response :unauthorized
    assert_equal [I18n.t('auth_form.invalid_password')], JSON.parse(response.body).dig('errors', 'password')
  end

  test "returns invalid token failure for invalid pending tokens" do
    session[:pending_login_token] = 'notatoken'

    post :create

    assert_response :unauthorized
    assert_equal [I18n.t('auth_form.invalid_token')], JSON.parse(response.body).dig('errors', 'token')
  end

  test "does not sign in a nil password" do
    User.create!(email: "sessionsuser3@example.com", email_verified: true)
    
    post :create, params: { user: { email: "sessionsuser3@example.com", password: nil } }
    assert_response :unauthorized
  end

  test "signs in a user via token" do
    user = User.create!(email: "tokenuser@example.com", email_verified: true)
    token = LoginToken.create!(user: user)
    session[:pending_login_token] = token.token
    
    post :create
    assert token.reload.used
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "signs in a user via code and marks the token used" do
    user = User.create!(email: "codeuser@example.com", email_verified: true)
    token = LoginToken.create!(user: user)

    post :create, params: { user: { email: user.email, code: token.code } }
    assert token.reload.used
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "does not sign in with an expired code" do
    user = User.create!(email: "expiredcodeuser@example.com", email_verified: true)
    token = LoginToken.create!(user: user, created_at: 25.hours.ago)

    post :create, params: { user: { email: user.email, code: token.code } }
    refute token.reload.used
    assert_response :unauthorized
  end

  test "does not sign in with a used code" do
    user = User.create!(email: "usedcodeuser@example.com", email_verified: true)
    token = LoginToken.create!(user: user, used: true)

    post :create, params: { user: { email: user.email, code: token.code } }
    assert_response :unauthorized
  end

  test "does not sign in a user with a used token" do
    user = User.create!(email: "usedtoken@example.com", email_verified: true)
    token = LoginToken.create!(user: user, used: true)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :unauthorized
  end

  test "does not sign in a user with an expired token" do
    user = User.create!(email: "expiredtoken@example.com", email_verified: true)
    token = LoginToken.create!(user: user, created_at: 25.hours.ago)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :unauthorized
  end

  test "does not sign in a user with an invalid token id" do
    session[:pending_login_token] = 'notatoken'
    
    post :create
    assert_response :unauthorized
  end

  test "finds a verified user to sign in" do
    user = User.create!(email: "verified@example.com", email_verified: true)
    User.create!(email: "unverified@example.com", email_verified: false)
    token = LoginToken.create!(user: user)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "signs in an unverified user" do
    unverified_user = User.create!(email: "unverified2@example.com", email_verified: false)
    token = LoginToken.create!(user: unverified_user)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal unverified_user.id, json['current_user_id']
  end
end
