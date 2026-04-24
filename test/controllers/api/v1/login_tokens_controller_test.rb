require 'test_helper'

class Api::V1::LoginTokensControllerTest < ActionController::TestCase
  setup do
    @original_turnstile_secret = ENV['TURNSTILE_SECRET_KEY']
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_turnstile_secret
  end

  test "create creates a new login token" do
    user = users(:user)
    assert_difference -> { user.login_tokens.count }, 1 do
      post :create, params: { email: user.email }
    end
    assert_response :success
  end

  test "create updates detected locale" do
    user = users(:user)
    user.update_detected_locale('en')
    @request.headers['HTTP_ACCEPT_LANGUAGE'] = 'es'
    post :create, params: { email: user.email }
    assert_equal 'es', user.reload.detected_locale
    assert_response :success
  end

  test "create does not create a login token if no email is present" do
    user = users(:user)
    assert_no_difference -> { user.login_tokens.count } do
      post :create
    end
    assert_response :bad_request
  end

  test "create does not create a login token for an email we dont have" do
    assert_no_difference -> { LoginToken.count } do
      post :create, params: { email: "notathing@example.com" }
    end
    assert_response :success
  end

  test "turnstile required: rejects request without token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    user = users(:normal_user)
    assert_no_difference -> { LoginToken.count } do
      post :create, params: { email: user.email }
    end
    assert_response :forbidden
  end

  test "turnstile required: accepts request with valid token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    user = users(:normal_user)
    assert_difference -> { user.login_tokens.count }, 1 do
      post :create, params: { email: user.email, turnstile_token: "cf-ok" }
    end
    assert_response :success
  end

  test "turnstile required: rejects when Cloudflare says no" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: false }.to_json, headers: { 'Content-Type' => 'application/json' })
    user = users(:normal_user)
    assert_no_difference -> { LoginToken.count } do
      post :create, params: { email: user.email, turnstile_token: "cf-bad" }
    end
    assert_response :forbidden
  end
end
