require 'test_helper'

class SpamRuleEnforcementTest < ActionDispatch::IntegrationTest
  setup do
    @env_before = ENV.slice('TURNSTILE_SECRET_KEY', 'FEATURES_DISABLE_LOCAL_LOGIN', 'FEATURES_DISABLE_CREATE_USER')
    @env_before.keys.each { |key| ENV.delete(key) }
    @user = users(:user)
    @user.update!(password: 'Spam-rule-test-password')
    @domain = @user.email.split('@').last
  end

  teardown do
    %w[TURNSTILE_SECRET_KEY FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_CREATE_USER].each do |key|
      @env_before.key?(key) ? ENV[key] = @env_before[key] : ENV.delete(key)
    end
  end

  test 'new signup and trial requests are denied before creating users tokens or groups' do
    rule = SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')
    assert_no_difference [ 'User.count', 'LoginToken.count', 'Group.count' ] do
      post '/api/v1/registrations', params: { user: { email: 'new@blocked.example' } }, as: :json
      assert_response :forbidden
      post '/api/v1/trials', params: { user_email: 'new@blocked.example', user_name: 'New user', group_name: 'A group' }, as: :json
      assert_response :forbidden
    end
    assert_equal 2, rule.hits.where(action: 'signup').sum(:count)
  end

  test 'password authentication is denied without creating a session' do
    rule = SpamRule.create!(kind: 'email_domain', pattern: @domain)
    assert_no_difference 'Session.count' do
      sign_in_request
      assert_response :forbidden
    end
    assert_equal 1, rule.hits.where(action: 'sign_in').sum(:count)
  end

  test 'email codes are denied before they are consumed' do
    token = LoginToken.create!(user: @user)
    SpamRule.create!(kind: 'email_domain', pattern: @domain)
    assert_no_difference 'Session.count' do
      post '/api/v1/sessions', params: { user: { email: @user.email, code: token.code } }, as: :json
    end
    assert_response :forbidden
    assert_nil token.reload.used_at
  end

  test 'existing browser sessions are denied on their next request and restored by disabling the rule' do
    sign_in_request
    assert_response :success
    session_record = @user.sessions.order(:id).last
    rule = SpamRule.create!(kind: 'email_domain', pattern: @domain)
    get '/api/v1/profile/email_api_key', as: :json
    assert_response :forbidden
    assert_not_includes response.body, @user.email_api_key
    assert session_record.reload.active?
    assert @user.reload.active?
    rule.discard!
    get '/api/v1/profile/email_api_key', as: :json
    assert_response :success
    assert_equal 1, rule.hits.where(action: 'access').sum(:count)
  end

  test 'IP bans deny signed-in users and admins without changing their accounts' do
    sign_in_request
    rule = SpamRule.create!(kind: 'ip', pattern: '198.51.100.0/24')
    get '/api/v1/profile/email_api_key', headers: { 'REMOTE_ADDR' => '198.51.100.7' }, as: :json
    assert_response :forbidden
    assert_equal I18n.t('errors.403.title'), response.parsed_body['error']
    get '/api/v1/profile/email_api_key', headers: { 'REMOTE_ADDR' => '203.0.113.7' }, as: :json
    assert_response :success
    assert @user.reload.active?
    assert_equal 1, rule.hits.sum(:count)
  end

  test 'existing API keys are denied until their email rule expires' do
    rule = SpamRule.create!(kind: 'email_domain', pattern: @domain, expires_at: 1.minute.from_now)
    headers = { 'Authorization' => "Bearer #{@user.api_key}" }
    get '/api/user0/groups', headers: headers, as: :json
    assert_response :forbidden
    travel 2.minutes do
      get '/api/user0/groups', headers: headers, as: :json
      assert_response :success
    end
    assert_equal 1, rule.hits.where(action: 'access').sum(:count)
  end

  private

  def sign_in_request
    post '/api/v1/sessions', params: { user: { email: @user.email, password: 'Spam-rule-test-password' } }, as: :json
  end
end
