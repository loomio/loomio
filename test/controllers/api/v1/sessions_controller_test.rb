require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
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
