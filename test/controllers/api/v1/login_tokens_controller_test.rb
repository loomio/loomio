require 'test_helper'

class Api::V1::LoginTokensControllerTest < ActionController::TestCase
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
    assert_response :not_found
  end
end
