require 'test_helper'

class AccountCompletionTest < ActionDispatch::IntegrationTest
  setup do
    @forgery_before = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    @saved_env = %w[FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_EMAIL_LOGIN TURNSTILE_SECRET_KEY TERMS_URL LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS].to_h { |key| [key, ENV.delete(key)] }
    ENV['TERMS_URL'] = 'https://example.com/terms'
  end

  teardown do
    ActionController::Base.allow_forgery_protection = @forgery_before
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  test 'a consumed completion cookie cannot create another session after logout' do
    user, saved_cookie = stage_with_code
    complete_account
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
    assert_empty AccountCompletionProof.where(user: user)
    delete '/api/v1/sessions', headers: csrf_headers, as: :json
    assert_response :success

    assert_replay_rejected(user, saved_cookie)
  end

  test 'logout revokes an unconsumed completion cookie' do
    user, saved_cookie = stage_with_code
    delete '/api/v1/sessions', headers: csrf_headers, as: :json
    assert_response :success
    assert_empty AccountCompletionProof.where(user: user)

    assert_replay_rejected(user, saved_cookie)
  end

  test 'signing in to another account revokes the earlier completion cookie' do
    user, saved_cookie = stage_with_code
    other = User.create!(email: 'other-completion@example.com', name: 'Other Person', email_verified: true, legal_accepted: true)
    token = LoginToken.create!(user: other)
    post '/api/v1/sessions', params: { user: { email: other.email, code: token.code } }, headers: csrf_headers, as: :json
    assert_response :success
    assert_equal other.id, response.parsed_body['current_user_id']
    assert_empty AccountCompletionProof.where(user: user)

    assert_replay_rejected(user, saved_cookie)
  end

  test 'a replacement completion proof revokes the previous cookie' do
    user, saved_cookie = stage_with_code
    token = LoginToken.create!(user: user)
    post '/api/v1/sessions', params: { user: { email: user.email, code: token.code } }, headers: csrf_headers, as: :json
    assert_response :success
    replacement_cookie = cookies['_loomio']

    assert_replay_rejected(user, saved_cookie)
    cookies['_loomio'] = replacement_cookie
    get '/dashboard'
    complete_account
    assert_response :success
  end

  test 'invalid completion retains the proof for a corrected submission' do
    user, = stage_with_code
    assert_no_difference ['Session.count', 'AccountCompletionProof.count'] do
      complete_account(name: '', legal_accepted: false)
    end
    assert_response :unprocessable_entity
    assert_nil user.reload.name
    assert_nil user.legal_accepted_at
    complete_account
    assert_response :success
    assert_empty AccountCompletionProof.where(user: user)
  end

  test 'previously active account can complete a missing name without asserting terms acceptance' do
    user = User.create!(email: 'returning-name@example.com', email_verified: true, current_sign_in_at: 1.week.ago)
    token = LoginToken.create!(user: user)
    get '/dashboard'

    assert_no_difference 'Session.count' do
      post '/api/v1/sessions', params: { user: { email: user.email, code: token.code } }, headers: csrf_headers, as: :json
    end
    assert_response :success
    assert_equal false, response.parsed_body['legal_acceptance_required']

    assert_difference 'Session.count', 1 do
      complete_account(name: 'Returning Person', legal_accepted: false)
    end
    assert_response :success
    assert_equal 'Returning Person', user.reload.name
    assert_nil user.legal_accepted_at
  end

  test 'inactive accounts cannot consume a completion proof' do
    user, = stage_with_code
    user.update!(deactivated_at: Time.current)
    assert_no_difference 'Session.count' do
      complete_account
    end
    assert_response :unauthorized
    assert_nil user.reload[:name]
  end

  private

  def csrf_headers
    { 'X-CSRF-TOKEN' => cookies['csrftoken'], 'Origin' => 'null' }
  end

  def stage_with_code
    user = User.create!(email: 'completion-replay@example.com', email_verified: false)
    token = LoginToken.create!(user: user)
    get '/dashboard'
    assert cookies['csrftoken'].present?
    assert_no_difference 'Session.count' do
      post '/api/v1/sessions', params: { user: { email: user.email, code: token.code } }, headers: csrf_headers, as: :json
    end
    assert_response :success
    assert response.parsed_body['incomplete']
    assert AccountCompletionProof.exists?(user: user)
    [user, cookies['_loomio']]
  end

  def complete_account(name: 'Complete Person', legal_accepted: true)
    post '/api/v1/registrations/complete', params: { user: { name: name, legal_accepted: legal_accepted } }, headers: csrf_headers, as: :json
  end

  def assert_replay_rejected(user, cookie)
    profile = user.reload.attributes.slice('name', 'legal_accepted_at')
    cookies['_loomio'] = cookie
    get '/dashboard'
    assert_no_difference 'Session.count' do
      complete_account(name: 'Replay Person')
    end
    assert_response :unauthorized
    assert_equal profile, user.reload.attributes.slice('name', 'legal_accepted_at')
  end
end
