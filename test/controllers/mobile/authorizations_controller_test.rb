require "test_helper"

class Mobile::AuthorizationsControllerTest < ActionController::TestCase
  tests Mobile::AuthorizationsController

  setup do
    @user = User.create!(
      name: "Mobile User",
      username: "mobileauth#{SecureRandom.hex(4)}",
      email: "mobileauth#{SecureRandom.hex(4)}@example.com",
      email_verified: true
    )
    @params = {
      response_type: "code",
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      code_challenge: "c" * 43,
      code_challenge_method: "S256",
      state: "s" * 43
    }
  end

  test "sends a signed-out user through normal browser authentication" do
    get :show, params: @params

    assert_redirected_to dashboard_path
    assert_match %r{\A/mobile/authorize\?}, session[:return_to_after_authenticating]
  end

  test "shows confirmation and returns a code only after approval" do
    sign_in @user
    get :show, params: @params
    assert_response :success
    assert_includes response.body, @user.email
    assert_includes response.body, "Connect this device"

    post :create, params: { decision: "approve" }
    assert_response :redirect
    uri = URI.parse(response.location)
    query = URI.decode_www_form(uri.query).to_h
    assert_equal "org.loomio.mobile", uri.scheme
    assert_equal "/oauth/callback", uri.path
    assert_equal "s" * 43, query["state"]
    assert query["code"].start_with?("lm_ac_")
    assert_equal 1, MobileAuthorizationCode.count
  end

  test "rejects plain PKCE before authentication" do
    get :show, params: @params.merge(code_challenge_method: "plain")

    assert_response :bad_request
    assert_nil session[:return_to_after_authenticating]
  end

  test "rejects duplicate security parameters" do
    @request.query_string = URI.encode_www_form(@params) + "&state=other-state"
    get :show

    assert_response :bad_request
  end

  test "denial returns state without creating a credential" do
    sign_in @user
    get :show, params: @params
    post :create, params: { decision: "deny" }

    query = URI.decode_www_form(URI.parse(response.location).query).to_h
    assert_equal "s" * 43, query["state"]
    assert_equal "access_denied", query["error"]
    assert_equal 0, MobileAuthorizationCode.count
  end
end
