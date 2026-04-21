require 'test_helper'
require 'webmock/minitest'

class Identities::GoogleControllerTest < ActionController::TestCase
  setup do
    @hex = SecureRandom.hex(4)
    @saved_env = {}
    %w[GOOGLE_APP_KEY GOOGLE_APP_SECRET LOOMIO_SSO_FORCE_USER_ATTRS].each do |key|
      @saved_env[key] = ENV[key]
    end

    ENV['GOOGLE_APP_KEY'] = 'google_client_id'
    ENV['GOOGLE_APP_SECRET'] = 'google_client_secret'

    stub_request(:post, 'https://www.googleapis.com/oauth2/v4/token')
      .to_return(
        status: 200,
        body: { access_token: 'google_access_token' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, /googleapis\.com\/oauth2\/v2\/userinfo/)
      .to_return(
        status: 200,
        body: {
          id: "google_#{@hex}",
          name: 'Google User',
          email: "google-#{@hex}@example.com",
          picture: 'https://lh3.googleusercontent.com/photo.jpg'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    @saved_env.each { |key, val| ENV[key] = val }
    WebMock.reset!
  end

  test "redirects to Google OAuth with correct parameters" do
    get :oauth, params: { back_to: '/some/path' }
    assert_equal '/some/path', session[:back_to]
    assert_match(/accounts\.google\.com/, response.location)
    assert_includes response.location, 'client_id=google_client_id'
    assert_includes response.location, 'scope=email+profile'
  end

  test "rejects external back_to" do
    get :oauth, params: { back_to: 'https://evil.com' }
    assert_nil session[:back_to]
  end

  test "creates user and signs in" do
    get :create, params: { code: 'google_auth_code' }

    user = User.find_by(email: "google-#{@hex}@example.com")
    assert user
    assert user.email_verified?
    assert_equal 'Google User', user.name

    identity = Identity.find_by(identity_type: 'google', uid: "google_#{@hex}")
    assert identity
    assert_equal user.id, identity.user_id
    assert_redirected_to dashboard_path
  end

  test "does not auto-link to verified user" do
    User.create!(name: 'Existing', email: "google-#{@hex}@example.com", username: "gex#{@hex}", email_verified: true)

    get :create, params: { code: 'google_auth_code' }

    identity = Identity.find_by(identity_type: 'google', uid: "google_#{@hex}")
    assert_nil identity.user_id
  end

  test "links to unverified user and verifies email" do
    unverified = User.create!(name: 'Invited', email: "google-#{@hex}@example.com", username: "ginv#{@hex}", email_verified: false)

    get :create, params: { code: 'google_auth_code' }

    identity = Identity.find_by(identity_type: 'google', uid: "google_#{@hex}")
    assert_equal unverified.id, identity.user_id
    assert unverified.reload.email_verified?
  end
end
