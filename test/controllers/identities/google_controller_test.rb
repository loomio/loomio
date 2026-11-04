require 'test_helper'
require 'webmock/minitest'

class Identities::GoogleControllerTest < ActionController::TestCase
  setup do
    @hex = SecureRandom.hex(4)
    @saved_env = {}
    %w[GOOGLE_APP_KEY GOOGLE_APP_SECRET LOOMIO_SSO_FORCE_USER_ATTRS
       LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN TERMS_URL].each do |key|
      @saved_env[key] = ENV[key]
    end

    ENV['GOOGLE_APP_KEY'] = 'google_client_id'
    ENV['GOOGLE_APP_SECRET'] = 'google_client_secret'
    ENV.delete('TERMS_URL')

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

    stub_request(:get, 'https://lh3.googleusercontent.com/photo.jpg')
      .to_return(
        status: 200,
        body: File.binread(Rails.root.join('public/brand/icon-yellow-on-white-192.png')),
        headers: { 'Content-Type' => 'image/png' }
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
    assert_includes response.location, 'state='
    assert session[:oauth_state].present?
  end

  test "rejects external back_to" do
    get :oauth, params: { back_to: 'https://evil.com' }
    assert_nil session[:back_to]
  end

  test "creates user and signs in" do
    get :create, params: oauth_callback_params(code: 'google_auth_code')

    user = User.find_by(email: "google-#{@hex}@example.com")
    assert user
    assert user.email_verified?
    assert_equal 'Google User', user.name
    assert_equal 'uploaded', user.avatar_kind
    assert user.uploaded_avatar.attached?

    identity = Identity.find_by(identity_type: 'google', uid: "google_#{@hex}")
    assert identity
    assert_equal user.id, identity.user_id
    assert_redirected_to dashboard_path
  end

  test "auto-links to verified user" do
    existing = User.create!(name: 'Existing', email: "google-#{@hex}@example.com", username: "gex#{@hex}", email_verified: true)

    get :create, params: oauth_callback_params(code: 'google_auth_code')

    identity = Identity.find_by(identity_type: 'google', uid: "google_#{@hex}")
    assert_equal existing.id, identity.user_id
    assert_equal existing, @controller.current_user
  end

  test "preserves an uploaded avatar when SSO profile updates are disabled" do
    existing = create_user_with_uploaded_avatar
    avatar_blob_id = existing.uploaded_avatar.blob_id

    get :create, params: oauth_callback_params(code: 'google_auth_code')

    assert_equal avatar_blob_id, existing.reload.uploaded_avatar.blob_id
  end

  test "replaces an uploaded avatar when SSO profile updates are enabled" do
    existing = create_user_with_uploaded_avatar
    avatar_blob_id = existing.uploaded_avatar.blob_id
    ENV['LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN'] = '1'

    get :create, params: oauth_callback_params(code: 'google_auth_code')

    assert_not_equal avatar_blob_id, existing.reload.uploaded_avatar.blob_id
  end

  test "links to unverified user and verifies email" do
    unverified = User.create!(name: 'Invited', email: "google-#{@hex}@example.com", username: "ginv#{@hex}", email_verified: false)

    get :create, params: oauth_callback_params(code: 'google_auth_code')

    identity = Identity.find_by(identity_type: 'google', uid: "google_#{@hex}")
    assert_equal unverified.id, identity.user_id
    assert unverified.reload.email_verified?
  end

  private

  def create_user_with_uploaded_avatar
    User.create!(
      name: 'Existing',
      email: "google-#{@hex}@example.com",
      username: "gavatar#{@hex}",
      email_verified: true,
      avatar_kind: 'uploaded'
    ).tap do |user|
      user.uploaded_avatar.attach(
        io: File.open(Rails.root.join('public/brand/icon-yellow-on-white-256.png')),
        filename: 'existing-avatar.png'
      )
      user.update!(avatar_kind: 'uploaded')
    end
  end

  def oauth_callback_params(params = {})
    session[:oauth_state] = 'test-oauth-state'
    params.merge(state: 'test-oauth-state')
  end
end
