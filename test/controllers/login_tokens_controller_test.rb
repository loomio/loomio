require 'test_helper'

class LoginTokensControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @token = LoginToken.create!(user: @user)
  end

  test "sets a session variable and redirects to dashboard" do
    get :show, params: { token: @token.token }
    assert_equal @token.token, session[:pending_login_token]
    assert_redirected_to dashboard_path
  end

  test "redirects to the redirect path" do
    @token.update!(redirect: '/inbox')
    get :show, params: { token: @token.token }
    assert_redirected_to inbox_path
  end
end
