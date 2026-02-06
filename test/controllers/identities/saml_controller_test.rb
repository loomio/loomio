require 'test_helper'
require 'minitest/mock'

class Identities::SamlControllerTest < ActionController::TestCase
  setup do
    @saved_env = {}
    %w[SAML_IDP_METADATA_URL SAML_ISSUER LOOMIO_SSO_FORCE_USER_ATTRS].each do |key|
      @saved_env[key] = ENV[key]
    end
    ENV['SAML_IDP_METADATA_URL'] = 'https://saml.provider.com/metadata'
    ENV['SAML_ISSUER'] = 'https://loomio.test/saml/metadata'

    # Build mock SAML settings
    @mock_settings = OpenStruct.new(security: {})

    # Stub IdpMetadataParser to return mock settings
    @mock_parser = Minitest::Mock.new
    @mock_parser.expect(:parse_remote, @mock_settings, [String])

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    @saved_env.each { |key, val| ENV[key] = val }
  end

  # OAuth redirect tests
  test "redirects to SAML IdP with auth request" do
    mock_auth_request = Minitest::Mock.new
    mock_auth_request.expect(:create, 'https://saml.provider.com/login?SAMLRequest=...',
                              [OpenStruct])

    OneLogin::RubySaml::IdpMetadataParser.stub(:new, @mock_parser) do
      OneLogin::RubySaml::Authrequest.stub(:new, mock_auth_request) do
        get :oauth, params: { back_to: '/some/path' }
      end
    end

    assert_equal '/some/path', session[:back_to]
    assert_redirected_to 'https://saml.provider.com/login?SAMLRequest=...'
  end

  test "stores referrer as back_to when no back_to param" do
    mock_auth_request = Minitest::Mock.new
    mock_auth_request.expect(:create, 'https://saml.provider.com/login?SAMLRequest=...',
                              [OpenStruct])

    OneLogin::RubySaml::IdpMetadataParser.stub(:new, @mock_parser) do
      OneLogin::RubySaml::Authrequest.stub(:new, mock_auth_request) do
        request.env['HTTP_REFERER'] = 'http://test.host/previous/page'
        get :oauth
      end
    end

    assert_equal 'http://test.host/previous/page', session[:back_to]
  end

  # Create tests helpers
  private

  def mock_saml_response(valid: true, nameid: 'user@example.com', name: 'SAML User')
    response = OpenStruct.new(
      nameid: nameid,
      is_valid?: valid
    )
    response.define_singleton_method(:attributes) do
      { 'displayName' => name }
    end
    response.define_singleton_method(:settings=) do |s|
      # no-op
    end
    response
  end

  def with_saml_mocks(saml_response: nil, &block)
    saml_response ||= mock_saml_response
    OneLogin::RubySaml::IdpMetadataParser.stub(:new, @mock_parser) do
      OneLogin::RubySaml::Response.stub(:new, saml_response) do
        yield
      end
    end
  end

  public

  # Create tests - user does not exist
  test "creates user and signs in when user does not exist" do
    session[:back_to] = '/dashboard'

    with_saml_mocks do
      assert_difference ['Identity.where(identity_type: "saml").count', 'User.count'], 1 do
        post :create, params: { SAMLResponse: 'base64_encoded' }
      end
    end

    identity = Identity.where(identity_type: 'saml').last
    assert_equal 'user@example.com', identity.uid
    assert_equal 'user@example.com', identity.email
    assert_equal 'SAML User', identity.name
    assert identity.user.present?
    assert_equal 'user@example.com', identity.user.email
    assert_equal 'SAML User', identity.user.name
    assert_equal true, identity.user.email_verified

    assert_equal identity.user, @controller.current_user
    assert_redirected_to '/dashboard'
    assert_equal I18n.t('devise.sessions.signed_in'), flash[:notice]
  end

  # Create - user with same email exists
  test "attaches identity to existing user and signs in" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'user@example.com', username: "samluser#{hex}", email_verified: true)
    session[:back_to] = '/dashboard'

    with_saml_mocks do
      assert_difference 'Identity.where(identity_type: "saml").count', 1 do
        assert_no_difference 'User.count' do
          post :create, params: { SAMLResponse: 'base64_encoded' }
        end
      end
    end

    identity = Identity.where(identity_type: 'saml').last
    assert_equal existing_user, identity.user
    assert_equal 1, existing_user.reload.identities.count

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  test "does not overwrite user name by default" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'user@example.com', username: "samluser#{hex}", email_verified: true)

    with_saml_mocks do
      post :create, params: { SAMLResponse: 'base64_encoded' }
    end

    assert_equal 'Original Name', existing_user.reload.name
  end

  # Force user attrs
  test "overwrites name when sso_force_user_attrs is true" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'user@example.com', username: "samluser#{hex}", email_verified: true)
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = 'true'

    with_saml_mocks do
      post :create, params: { SAMLResponse: 'base64_encoded' }
    end

    existing_user.reload
    assert_equal 'SAML User', existing_user.name
    assert_equal 'user@example.com', existing_user.email
    assert_equal existing_user, @controller.current_user
  end

  # Unverified user
  test "verifies email for unverified user with same email" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'user@example.com', username: "samluser#{hex}", email_verified: false)
    session[:back_to] = '/dashboard'

    with_saml_mocks do
      assert_difference 'Identity.where(identity_type: "saml").count', 1 do
        assert_no_difference 'User.count' do
          post :create, params: { SAMLResponse: 'base64_encoded' }
        end
      end
    end

    identity = Identity.where(identity_type: 'saml').last
    assert_equal existing_user, identity.user
    assert_equal true, existing_user.reload.email_verified

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  # Regression test - identity missing
  test "links existing user to new identity without duplicate" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'user@example.com', username: "samluser#{hex}", email_verified: true)
    session[:back_to] = '/dashboard'

    with_saml_mocks do
      assert_difference 'Identity.where(identity_type: "saml").count', 1 do
        assert_no_difference 'User.count' do
          post :create, params: { SAMLResponse: 'base64_encoded' }
        end
      end
    end

    identity = Identity.where(identity_type: 'saml').last
    assert_equal existing_user, identity.user
    assert_equal 'user@example.com', identity.uid
  end

  # uid with different email, force attrs
  test "updates email from SSO when uid matches and force attrs enabled" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original Name', email: 'old@example.com', username: "samluser#{hex}", email_verified: true)
    existing_identity = Identity.create!(
      identity_type: 'saml',
      uid: 'user@example.com',
      email: 'old@example.com',
      name: 'Original Name',
      access_token: nil,
      user: existing_user
    )
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = 'true'
    session[:back_to] = '/dashboard'

    with_saml_mocks do
      assert_no_difference ['Identity.where(identity_type: "saml").count', 'User.count'] do
        post :create, params: { SAMLResponse: 'base64_encoded' }
      end
    end

    existing_identity.reload
    assert_equal 'user@example.com', existing_identity.email
    assert_equal 'SAML User', existing_identity.name

    existing_user.reload
    assert_equal 'user@example.com', existing_user.email
    assert_equal 'SAML User', existing_user.name

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  # Identity already exists with same uid
  test "updates identity and signs in existing user when uid matches" do
    hex = SecureRandom.hex(4)
    existing_user = User.create!(name: 'Original', email: "existing#{hex}@example.com", username: "samluser#{hex}", email_verified: true)
    existing_identity = Identity.create!(
      identity_type: 'saml',
      uid: 'user@example.com',
      email: 'old@example.com',
      access_token: nil,
      user: existing_user
    )
    session[:back_to] = '/dashboard'

    with_saml_mocks do
      assert_no_difference ['Identity.where(identity_type: "saml").count', 'User.count'] do
        post :create, params: { SAMLResponse: 'base64_encoded' }
      end
    end

    existing_identity.reload
    assert_equal 'user@example.com', existing_identity.uid
    assert_equal 'user@example.com', existing_identity.email
    assert_equal 'SAML User', existing_identity.name

    assert_equal existing_user, @controller.current_user
    assert_redirected_to '/dashboard'
  end

  # Already signed in
  test "creates pending identity when user already signed in" do
    hex = SecureRandom.hex(4)
    current_user = User.create!(name: "signed#{hex}", email: "signed#{hex}@example.com", username: "signed#{hex}", email_verified: true)
    sign_in current_user
    session[:back_to] = '/settings'

    with_saml_mocks do
      assert_difference 'Identity.where(identity_type: "saml").count', 1 do
        assert_no_difference -> { current_user.identities.count } do
          post :create, params: { SAMLResponse: 'base64_encoded' }
        end
      end
    end

    identity = Identity.where(identity_type: 'saml').last
    assert_nil identity.user_id
    assert_equal 'user@example.com', identity.email

    assert_equal identity.id, session[:pending_identity_id]
    assert_redirected_to '/settings'
    assert_equal I18n.t('auth.switching_accounts'), flash[:notice]
  end

  # Invalid SAML response
  test "returns error for invalid SAML response" do
    with_saml_mocks(saml_response: mock_saml_response(valid: false)) do
      post :create, params: { SAMLResponse: 'base64_encoded' }, format: :json
    end
    assert_response 500
    json = JSON.parse(response.body)
    assert_equal 'SAML response is not valid', json['error']
  end

  # Fallback redirect
  test "redirects to dashboard when no back_to is set" do
    with_saml_mocks do
      post :create, params: { SAMLResponse: 'base64_encoded' }
    end
    assert_redirected_to dashboard_path
  end

  # Metadata
  test "returns SAML metadata XML" do
    mock_metadata = Minitest::Mock.new
    mock_metadata.expect(:generate, '<xml>metadata</xml>', [Object])

    OneLogin::RubySaml::IdpMetadataParser.stub(:new, @mock_parser) do
      OneLogin::RubySaml::Metadata.stub(:new, mock_metadata) do
        get :metadata
      end
    end

    assert_includes response.content_type, 'application/samlmetadata+xml'
    assert_equal '<xml>metadata</xml>', response.body
  end

  # Destroy tests
  test "destroys identity connection" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "samluser#{hex}", email: "samluser#{hex}@example.com", username: "samluser#{hex}", email_verified: true)
    identity = Identity.create!(identity_type: 'saml', uid: 'saml_user_123', email: 'saml@example.com', access_token: nil, user: user)
    sign_in user
    request.env['HTTP_REFERER'] = 'http://test.host/settings'

    assert_difference -> { user.identities.count }, -1 do
      get :destroy
    end

    assert_nil Identity.find_by(id: identity.id, identity_type: 'saml')
    assert_redirected_to 'http://test.host/settings'
  end

  test "destroy redirects to root when no referrer" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "samluser#{hex}", email: "samluser#{hex}@example.com", username: "samluser#{hex}", email_verified: true)
    Identity.create!(identity_type: 'saml', uid: 'saml_user_123', email: 'saml@example.com', access_token: nil, user: user)
    sign_in user
    get :destroy
    assert_redirected_to root_path
  end

  test "destroy returns error when not connected to saml" do
    hex = SecureRandom.hex(4)
    user = User.create!(name: "samluser#{hex}", email: "samluser#{hex}@example.com", username: "samluser#{hex}", email_verified: true)
    sign_in user
    get :destroy, format: :json
    assert_response 500
    json = JSON.parse(response.body)
    assert json['error'].present?
  end
end
