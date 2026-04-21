require 'test_helper'
require 'webmock/minitest'

class Identities::NextcloudControllerTest < ActionController::TestCase
  setup do
    @hex = SecureRandom.hex(4)
    @saved_env = {}
    %w[NEXTCLOUD_HOST NEXTCLOUD_APP_KEY NEXTCLOUD_APP_SECRET LOOMIO_SSO_FORCE_USER_ATTRS].each do |key|
      @saved_env[key] = ENV[key]
    end

    ENV['NEXTCLOUD_HOST'] = 'https://cloud.example.com'
    ENV['NEXTCLOUD_APP_KEY'] = 'nc_client_id'
    ENV['NEXTCLOUD_APP_SECRET'] = 'nc_client_secret'

    stub_request(:post, 'https://cloud.example.com/index.php/apps/oauth2/api/v1/token')
      .to_return(
        status: 200,
        body: { access_token: 'nc_access_token' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, /cloud\.example\.com\/ocs\/v2\.php\/cloud\/user/)
      .to_return(
        status: 200,
        body: {
          ocs: {
            data: {
              id: "nc_#{@hex}",
              email: "nc-#{@hex}@example.com"
            }
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    @saved_env.each { |key, val| ENV[key] = val }
    WebMock.reset!
  end

  test "redirects to Nextcloud OAuth" do
    get :oauth, params: { back_to: '/some/path' }
    assert_equal '/some/path', session[:back_to]
    assert_match(/cloud\.example\.com/, response.location)
    assert_includes response.location, 'client_id=nc_client_id'
  end

  test "rejects external back_to" do
    get :oauth, params: { back_to: 'https://evil.com' }
    assert_nil session[:back_to]
  end

  test "creates user and signs in" do
    get :create, params: { code: 'nc_auth_code' }

    user = User.find_by(email: "nc-#{@hex}@example.com")
    assert user
    assert user.email_verified?

    identity = Identity.find_by(identity_type: 'nextcloud', uid: "nc_#{@hex}")
    assert identity
    assert_equal user.id, identity.user_id
    assert_redirected_to dashboard_path
  end

  test "does not auto-link to verified user" do
    User.create!(name: 'Existing', email: "nc-#{@hex}@example.com", username: "ncex#{@hex}", email_verified: true)

    get :create, params: { code: 'nc_auth_code' }

    identity = Identity.find_by(identity_type: 'nextcloud', uid: "nc_#{@hex}")
    assert_nil identity.user_id
  end

  test "links to unverified user and verifies email" do
    unverified = User.create!(name: 'Invited', email: "nc-#{@hex}@example.com", username: "ncinv#{@hex}", email_verified: false)

    get :create, params: { code: 'nc_auth_code' }

    identity = Identity.find_by(identity_type: 'nextcloud', uid: "nc_#{@hex}")
    assert_equal unverified.id, identity.user_id
    assert unverified.reload.email_verified?
  end
end
