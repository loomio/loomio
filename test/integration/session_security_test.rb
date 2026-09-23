require 'test_helper'

class SessionSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_EMAIL_LOGIN TURNSTILE_SECRET_KEY TERMS_URL].to_h { |key| [key, ENV.delete(key)] }
    @forgery_before = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    ActionController::Base.allow_forgery_protection = @forgery_before
  end

  %i[inactive_member_loud inactive_guest_loud].each do |role|
    %i[password code].each do |credential|
      test "#{role} cannot authenticate with #{credential}" do
        user = users(role)
        user.update!(password: 'inactive-password-123')
        credentials = if credential == :password
          { password: 'inactive-password-123' }
        else
          { code: LoginToken.create!(user: user).code }
        end
        get '/dashboard'

        assert_no_difference ['Session.count', 'AccountCompletionProof.count', -> { user.reload.sign_in_count.to_i }] do
          post '/api/v1/sessions', params: { user: { email: user.email, **credentials } }, headers: csrf_headers, as: :json
        end
        assert_response :unauthorized
        assert_nil response.parsed_body['current_user_id']
      end
    end
  end

  test 'deactivation denies the first protected request and destroys its session and push subscriptions' do
    user = users(:member_loud)
    authenticate(user)
    session_record = user.sessions.last
    subscription = create_push_subscription(user: user, session: session_record, endpoint: 'https://fcm.googleapis.com/fcm/send/inactive-session', p256dh_key: 'key', auth_key: 'auth')
    saved_cookie = cookies['session_id']
    user.update!(deactivated_at: Time.current)

    get '/api/v1/profile/email_api_key', as: :json

    assert_response :unauthorized
    refute_includes response.body, user.email_api_key
    assert_not Session.exists?(session_record.id)
    assert_not PushSubscription.exists?(subscription.id)

    cookies['session_id'] = saved_cookie
    get '/api/v1/profile/email_api_key', as: :json
    assert_response :unauthorized
  end

  test 'an inactive session cannot change the account on its first request' do
    user = users(:guest_loud)
    authenticate(user)
    user.update!(deactivated_at: Time.current)
    original_name = user.name

    post '/api/v1/profile/update_profile', params: { user: { name: 'Unauthorized change' } }, headers: csrf_headers, as: :json

    assert_response :unauthorized
    assert_equal original_name, user.reload.name
  end

  private

  def authenticate(user)
    token = LoginToken.create!(user: user)
    get '/dashboard'
    post '/api/v1/sessions', params: { user: { email: user.email, code: token.code } }, headers: csrf_headers, as: :json
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
  end

  def csrf_headers
    { 'X-CSRF-TOKEN' => cookies['csrftoken'], 'Origin' => 'null' }
  end
end
