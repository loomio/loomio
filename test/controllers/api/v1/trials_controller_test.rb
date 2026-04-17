require 'test_helper'

class Api::V1::TrialsControllerTest < ActionController::TestCase
  setup do
    @original_turnstile_secret = ENV['TURNSTILE_SECRET_KEY']
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_turnstile_secret
  end

  test "turnstile required: rejects trial creation without token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    assert_no_difference 'User.count' do
      post :create, params: { user_name: "Jim", user_email: "jim-captcha@example.com", group_name: "x", group_category: "boards" }
    end
    assert_response :forbidden
  end

  test "turnstile required: accepts trial creation with valid token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    assert_difference 'User.count', 1 do
      post :create, params: {
        user_name: "Jim", user_email: "jim-cf-ok@example.com",
        group_name: "Jim group", group_category: "boards",
        group_description: "Make decisions",
        group_how_did_you_hear_about_loomio: "test",
        user_email_newsletter: true, user_legal_accepted: true,
        turnstile_token: "cf-ok"
      }
    end
    assert_response :success
  end

  test "turnstile required: rejects when Cloudflare says no" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: false }.to_json, headers: { 'Content-Type' => 'application/json' })
    assert_no_difference 'User.count' do
      post :create, params: {
        user_name: "Jim", user_email: "jim-cf-bad@example.com",
        group_name: "x", group_category: "boards",
        turnstile_token: "cf-bad"
      }
    end
    assert_response :forbidden
  end

  test "invalid email returns error" do
    post :create, params: {
      user_email: "invalid_email",
      user_name: "normal name"
    }
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"]["user_email"], "Not a valid email"
  end

  test "existing email returns error" do
    User.create!(email: "verified@example.com", email_verified: true)
    post :create, params: {
      user_email: "verified@example.com",
      user_name: "normal name"
    }
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"]["user_email"], "Email address already exists. Please sign in to continue."
  end

  test "creates new user and group and sends login email" do
    post :create, params: {
      user_name: "Jimmy",
      user_email: "jimmy@example.com",
      group_name: "Jim group",
      group_description: "Make decisions",
      group_category: "boards",
      group_how_did_you_hear_about_loomio: "I work there",
      user_email_newsletter: true,
      user_legal_accepted: true
    }
    assert_response :success
    
    user = User.find_by(email: 'jimmy@example.com')
    assert_equal "Jimmy", user.name
    assert user.email_newsletter
    
    group = user.adminable_groups.first
    assert_equal "/#{group.handle}", JSON.parse(response.body)['group_path']
    assert_equal "Jim group", group.name
    assert_equal "jim-group", group.handle
    assert_includes group.description, "Make decisions"
    assert_equal "boards", group.category
    assert_equal "I work there", group.info['how_did_you_hear_about_loomio']
  end
end
