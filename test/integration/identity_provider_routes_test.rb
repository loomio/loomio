require 'test_helper'

class IdentityProviderRoutesTest < ActionDispatch::IntegrationTest
  setup do
    @saved_app_keys = Identity::PROVIDERS.to_h do |provider|
      key = "#{provider.upcase}_APP_KEY"
      [key, ENV.delete(key)]
    end
  end

  teardown do
    @saved_app_keys.each { |key, value| ENV[key] = value }
  end

  test "provider routes return not found when their provider is disabled" do
    Identity::PROVIDERS.each do |provider|
      get "/#{provider}/oauth"
      assert_response :not_found

      get "/#{provider}/authorize"
      assert_response :not_found

      delete "/#{provider}"
      assert_response :not_found
    end

    post '/saml/oauth'
    assert_response :not_found

    get '/saml/metadata'
    assert_response :not_found
  end
end
