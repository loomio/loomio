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

  test "development redirects use the configured origin for explicit and default destinations" do
    keys = %w[CANONICAL_HOST CANONICAL_PORT FORCE_SSL]
    saved_env = ENV.slice(*keys)
    ENV['CANONICAL_HOST'] = 'canonical.example.test'
    ENV['CANONICAL_PORT'] = '3000'
    ENV.delete('FORCE_SSL')

    Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new('development')) do
      [nil, '/inbox'].each do |destination|
        @token.update!(redirect: destination)

        get :show, params: { token: @token.token }

        assert_redirected_to "http://canonical.example.test:3000#{destination || dashboard_path}"
        assert_equal @token.token, session[:pending_login_token]
      end
    end
  ensure
    keys.each { |key| ENV.delete(key) }
    saved_env.each { |key, value| ENV[key] = value }
  end

  test "stores an expired token in session so auth form can show invalid token error" do
    @token.update!(created_at: 25.hours.ago)
    get :show, params: { token: @token.token }
    assert_equal @token.token, session[:pending_login_token]
    assert_redirected_to dashboard_path
  end

  test "stores a used token in session so auth form can show invalid token error" do
    @token.update!(used: true)
    get :show, params: { token: @token.token }
    assert_equal @token.token, session[:pending_login_token]
    assert_redirected_to dashboard_path
  end
end
