require 'test_helper'

class SessionSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[FEATURES_DISABLE_LOCAL_LOGIN FEATURES_DISABLE_EMAIL_LOGIN TURNSTILE_SECRET_KEY TERMS_URL].to_h { |key| [ key, ENV.delete(key) ] }
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

        assert_no_difference [ 'Session.count', 'AccountCompletionProof.count', -> { user.reload.sign_in_count.to_i } ] do
          post '/api/v1/sessions', params: { user: { email: user.email, **credentials } }, headers: csrf_headers, as: :json
        end
        assert_response :unauthorized
        assert_nil response.parsed_body['current_user_id']
      end
    end
  end

  test 'deactivation denies the first protected request and revokes its session and push subscriptions' do
    user = users(:member_loud)
    authenticate(user)
    session_record = user.sessions.last
    subscription = create_push_subscription(user: user, session: session_record, endpoint: 'https://fcm.googleapis.com/fcm/send/inactive-session', p256dh_key: 'key', auth_key: 'auth')
    saved_cookie = cookies['session_id']
    user.update!(deactivated_at: Time.current)

    get '/api/v1/profile/email_api_key', as: :json

    assert_response :unauthorized
    refute_includes response.body, user.email_api_key
    refute session_record.reload.active?
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

  test 'logout retains the same revoked row without allowing the old cookie to authenticate' do
    user = users(:member_loud)
    authenticate(user)
    session_record = user.sessions.last
    saved_cookie = cookies['session_id']

    assert_no_difference 'Session.count' do
      delete '/api/v1/sessions', headers: csrf_headers, as: :json
    end
    assert_response :success
    refute session_record.reload.active?
    assert_equal user.id, session_record.user_id

    cookies['session_id'] = saved_cookie
    get '/api/v1/profile/email_api_key', as: :json
    assert_response :unauthorized
    refute_includes response.body, user.email_api_key
  end

  test 'a retained revoked session cannot access the job administration engine' do
    user = users(:server_admin)
    authenticate(user)
    record = user.sessions.last
    applications_before = MissionControl::Jobs.applications
    adapter = ActiveJob::QueueAdapters::AsyncAdapter.new
    MissionControl::Jobs.applications = MissionControl::Jobs::Applications.new.tap do |applications|
      applications.add('Session security', default: adapter)
    end
    get '/admin/jobs'
    assert request.path_parameters[:controller].to_s.start_with?('mission_control/jobs/')

    record.revoke!
    get '/admin/jobs'

    refute request.path_parameters[:controller].to_s.start_with?('mission_control/jobs/')
  ensure
    MissionControl::Jobs.applications = applications_before if applications_before
    adapter&.shutdown
  end

  test 'clearing an email block requires a valid administrator session and CSRF token' do
    administrator = users(:admin)
    recipient = users(:member_normal)
    authenticate(administrator)
    record = EmailSuppressionService.record!(email: recipient.email, reason: 'complaint', source_key: 'test:csrf')

    post clear_email_suppressions_admin_user_path(recipient), headers: { 'Origin' => 'https://untrusted.example' }
    assert_response :unprocessable_entity
    assert_nil record.reload.cleared_at
    post clear_email_suppressions_admin_user_path(recipient), headers: csrf_headers
    assert_redirected_to admin_user_path(recipient)
    assert_equal administrator.id, record.reload.cleared_by_id
  end

  test 'the signed-in app page is not stored by browsers or proxies' do
    authenticate(users(:member_loud))

    get '/dashboard'

    assert_response :success
    assert_equal 'no-store', response.headers['Cache-Control']
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
