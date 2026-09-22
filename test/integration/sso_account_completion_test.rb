require 'test_helper'

class SsoAccountCompletionTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[
      FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_EMAIL_LOGIN TERMS_URL
      OAUTH_APP_KEY OAUTH_APP_SECRET OAUTH_AUTH_URL OAUTH_TOKEN_URL OAUTH_PROFILE_URL OAUTH_SCOPE
      OAUTH_ATTR_UID OAUTH_ATTR_NAME OAUTH_ATTR_EMAIL
      SAML_APP_KEY SAML_IDP_METADATA SAML_IDP_METADATA_URL SAML_ATTR_EMAIL SAML_ATTR_NAME
      SAML_ATTR_GIVEN_NAME SAML_ATTR_FAMILY_NAME SAML_ALLOW_IDP_INITIATED
      LOOMIO_SSO_FORCE_USER_ATTRS LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN
    ].to_h { |key| [key, ENV.delete(key)] }
    ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = '1'
    ENV['TERMS_URL'] = 'https://example.com/terms'
    @forgery_before = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    ActionController::Base.allow_forgery_protection = @forgery_before
  end

  [true, false].each do |provider_supplies_name|
    test "OAuth callback completes in SSO-only mode with provider name #{provider_supplies_name}" do
      ENV.update(
        'OAUTH_APP_KEY' => 'client', 'OAUTH_APP_SECRET' => 'secret',
        'OAUTH_AUTH_URL' => 'https://provider.example/authorize',
        'OAUTH_TOKEN_URL' => 'https://provider.example/token',
        'OAUTH_PROFILE_URL' => 'https://provider.example/profile', 'OAUTH_SCOPE' => 'openid email profile'
      )
      profile = { sub: 'sso-completion', email: 'sso-completion@example.com' }
      profile[:name] = 'Provider Person' if provider_supplies_name
      stub_request(:post, ENV['OAUTH_TOKEN_URL']).to_return(status: 200, body: { access_token: 'token' }.to_json, headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, ENV['OAUTH_PROFILE_URL']).to_return(status: 200, body: profile.to_json, headers: { 'Content-Type' => 'application/json' })

      get '/oauth/oauth'
      state = Rack::Utils.parse_query(URI(response.location).query).fetch('state')
      assert_no_difference 'Session.count' do
        get '/oauth/authorize', params: { code: 'code', state: state }
      end
      assert_response :redirect
      complete_and_check_policy(provider_supplies_name)
    end

    test "SAML callback completes in SSO-only mode with provider name #{provider_supplies_name}" do
      ENV['SAML_APP_KEY'] = '1'
      ENV['SAML_IDP_METADATA_URL'] = 'https://provider.example/metadata'
      settings = OneLogin::RubySaml::Settings.new
      parser = Minitest::Mock.new
      2.times { parser.expect(:parse_remote, settings, [String]) }
      auth_request = Minitest::Mock.new
      auth_request.expect(:uuid, '_completion_request')
      auth_request.expect(:create, 'https://provider.example/login', [OneLogin::RubySaml::Settings])
      saml_response = Minitest::Mock.new
      saml_response.expect(:is_valid?, true)
      saml_response.expect(:nameid, 'sso-completion@example.com')
      saml_response.expect(:attributes, provider_supplies_name ? { 'displayName' => 'Provider Person' } : {})

      OneLogin::RubySaml::IdpMetadataParser.stub(:new, parser) do
        OneLogin::RubySaml::Authrequest.stub(:new, auth_request) { get '/saml/oauth' }
        assert_response :redirect
        OneLogin::RubySaml::Response.stub(:new, ->(_payload, **options) {
          assert_equal '_completion_request', options[:matches_request_id]
          saml_response
        }) do
          assert_no_difference 'Session.count' do
            post '/saml/oauth', params: { SAMLResponse: 'signed-provider-response' }
          end
        end
      end
      assert_response :redirect
      parser.verify
      auth_request.verify
      saml_response.verify
      complete_and_check_policy(provider_supplies_name)
    end
  end

  private

  def complete_and_check_policy(provider_supplies_name)
    user = User.find_by!(email: 'sso-completion@example.com')
    assert_nil user.legal_accepted_at
    proof = AccountCompletionProof.find_by!(user: user)
    assert_equal provider_supplies_name, proof.name_managed?
    get '/dashboard'
    headers = { 'X-CSRF-TOKEN' => cookies['csrftoken'], 'Origin' => 'null' }
    assert_difference 'Session.count', 1 do
      post '/api/v1/registrations/complete', params: { user: { name: 'Entered Person', legal_accepted: true } }, headers: headers, as: :json
    end
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
    assert_equal provider_supplies_name ? 'Provider Person' : 'Entered Person', user.reload.name
    assert user.legal_accepted_at.present?
    assert_not AccountCompletionProof.exists?(proof.id)

    headers['X-CSRF-TOKEN'] = cookies['csrftoken']
    post '/api/v1/registrations', params: { user: { email: 'native@example.com' } }, headers: headers, as: :json
    assert_response :forbidden
    headers['X-CSRF-TOKEN'] = cookies['csrftoken']
    post '/api/v1/sessions', params: { user: { email: user.email, password: 'password' } }, headers: headers, as: :json
    assert_response :forbidden
  end
end
