require 'test_helper'

class Admin::SpamRulesControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @rule = SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example', reason: 'Confirmed campaign')
    sign_in @admin
  end

  test 'only instance admins can view and change or test rules' do
    [ nil, users(:user) ].each do |user|
      user ? sign_in(user) : sign_out
      get :index
      assert_redirected_to dashboard_path
      assert_no_difference 'SpamRule.count' do
        post :create, params: { spam_rule: { kind: 'ip', pattern: '198.51.100.1' } }
        assert_redirected_to dashboard_path
      end
      patch :disable, params: { id: @rule.id }
      assert_redirected_to dashboard_path
      assert_not @rule.reload.discarded?
      post :test_pattern, params: { value: 'a@blocked.example', target: 'email' }
      assert_redirected_to dashboard_path
    end
  end

  test 'index explains all effects and shows activity without counting admin views' do
    SpamRuleHit.record!(rule_id: @rule.id, action: 'signup', count: 3)
    assert_no_difference 'SpamRuleHit.sum(:count)' do
      get :index
      assert_response :success
      assert_includes response.body, 'existing signed-in users'
      assert_includes response.body, 'Accounts and content are retained'
      assert_includes response.body, 'Last hour'
      assert_includes response.body, '30 days'
      assert_includes response.body, 'Test a value'
    end
  end

  test 'create edit update disable restore and history are available' do
    get :new
    assert_response :success
    assert_difference 'SpamRule.count', 1 do
      post :create, params: { spam_rule: { kind: 'ip', pattern: '198.51.100.0/24', reason: 'Confirmed sender' } }
    end
    rule = SpamRule.order(:id).last
    assert_redirected_to admin_spam_rule_path(rule)
    assert_equal @admin.id.to_s, rule.versions.last.whodunnit.to_s
    get :edit, params: { id: rule.id }
    assert_response :success
    patch :update, params: { id: rule.id, spam_rule: { reason: 'Reviewed', expires_at: 1.day.from_now.iso8601 } }
    assert_redirected_to admin_spam_rule_path(rule)
    assert_equal 'Reviewed', rule.reload.reason
    patch :disable, params: { id: rule.id }
    assert rule.reload.discarded?
    patch :restore, params: { id: rule.id }
    assert_not rule.reload.discarded?
    get :show, params: { id: rule.id }
    assert_response :success
    assert_includes response.body, 'Change history'
    assert_includes response.body, 'Blocked actions'
    assert_includes response.body, 'Sign in'
  end

  test 'invalid patterns and expiry leave the previous rule unchanged' do
    patch :update, params: { id: @rule.id, spam_rule: { kind: 'regex', pattern: '[' } }
    assert_response :unprocessable_entity
    assert_equal 'blocked.example', @rule.reload.pattern
    patch :update, params: { id: @rule.id, spam_rule: { expires_at: 'nonsense' } }
    assert_response :unprocessable_entity
    assert_nil @rule.reload.expires_at
  end

  test 'testing reports matching active rules without recording hits' do
    assert_no_difference 'SpamRuleHit.count' do
      post :test_pattern, params: { target: 'email', value: 'a@blocked.example' }
    end
    assert_response :success
    assert_includes response.body, 'Matching active rules'
    assert_includes response.body, admin_spam_rule_path(@rule)
    @rule.discard!
    post :test_pattern, params: { target: 'email', value: 'a@blocked.example' }
    assert_includes response.body, 'No active rules match'
  end

  test 'admin filters distinguish active expired and disabled rules' do
    expired = SpamRule.create!(kind: 'ip', pattern: '203.0.113.5', expires_at: 1.day.ago)
    disabled = SpamRule.create!(kind: 'regex', pattern: 'disabled-pattern', discarded_at: Time.current)
    get :index, params: { state: 'expired' }
    assert_includes response.body, admin_spam_rule_path(expired)
    assert_not_includes response.body, admin_spam_rule_path(@rule)
    get :index, params: { state: 'disabled' }
    assert_includes response.body, admin_spam_rule_path(disabled)
    get :index, params: { kind: 'email_domain', q: 'blocked' }
    assert_includes response.body, admin_spam_rule_path(@rule)
    assert_not_includes response.body, admin_spam_rule_path(expired)
  end
end
