require 'test_helper'

class Api::V1::ProfileControllerTest < ActionController::TestCase
  inline_jobs "destroy deactivates the users account"
  setup do
    @user = users(:user)
    @alien = users(:alien)
    @group = groups(:group)
    @disable_edit_user_profile_previous = ENV.delete('LOOMIO_DISABLE_EDIT_USER_PROFILE')
    @disable_local_login_previous = ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN')
    @terms_url_previous = ENV['TERMS_URL']
    @enforce_existing_terms_previous = ENV.delete('LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS')
  end

  teardown do
    if @disable_edit_user_profile_previous
      ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'] = @disable_edit_user_profile_previous
    else
      ENV.delete('LOOMIO_DISABLE_EDIT_USER_PROFILE')
    end
    @disable_local_login_previous.nil? ? ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN') : ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = @disable_local_login_previous
    @terms_url_previous.nil? ? ENV.delete('TERMS_URL') : ENV['TERMS_URL'] = @terms_url_previous
    @enforce_existing_terms_previous.nil? ? ENV.delete('LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS') : ENV['LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS'] = @enforce_existing_terms_previous
  end

  test "account completion requires name and legal acceptance together" do
    ENV['TERMS_URL'] = 'https://example.com/terms'
    ENV['LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS'] = '1'
    @user.update_columns(name: nil, legal_accepted_at: nil)
    sign_in @user

    post :update_profile, params: { user: { name: 'Completed User' } }, format: :json

    assert_response :unprocessable_entity
    assert_nil @user.reload.name
    assert_nil @user.legal_accepted_at
  end

  test "account completion saves name and legal acceptance" do
    ENV['TERMS_URL'] = 'https://example.com/terms'
    ENV['LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS'] = '1'
    @user.update_columns(name: nil, legal_accepted_at: nil)
    sign_in @user

    post :update_profile, params: { user: { name: 'Completed User', legal_accepted: true, email_newsletter: true } }, format: :json

    assert_response :success
    assert_equal 'Completed User', @user.reload.name
    assert @user.legal_accepted_at.present?
    assert @user.email_newsletter?
  end

  test "previously active account can complete its name without asserting legal acceptance" do
    ENV['TERMS_URL'] = 'https://example.com/terms'
    @user.update_columns(name: nil, legal_accepted_at: nil, current_sign_in_at: 1.week.ago)
    sign_in @user

    post :update_profile, params: { user: { name: 'Completed User' } }, format: :json

    assert_response :success
    assert_equal 'Completed User', @user.reload.name
    assert_nil @user.legal_accepted_at
  end

  test "show returns the user json" do
    sign_in @user
    get :show, params: { id: @alien.username }, format: :json
    json = JSON.parse(response.body)
    assert_includes json.keys, 'users'
    assert_includes json['users'][0].keys, 'id'
    assert_includes json['users'][0].keys, 'name'
    assert_equal @alien.name, json['users'][0]['name']
  end

  test "show can fetch a user by username" do
    sign_in @user
    get :show, params: { id: @alien.username }, format: :json
    json = JSON.parse(response.body)
    assert_equal @alien.username, json['users'][0]['username']
  end

  test "me returns the current user data" do
    sign_in @user
    get :me, format: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @user.id, json.dig('users', 0, 'id')
  end

  test "boot reports required legal acceptance when existing-user enforcement is enabled" do
    ENV['TERMS_URL'] = 'https://example.com/terms'
    ENV['LOOMIO_ENFORCE_TERMS_FOR_EXISTING_USERS'] = '1'
    @user.update_columns(legal_accepted_at: nil, current_sign_in_at: 1.week.ago)
    sign_in @user

    payload = Boot::User.new(@user.reload, root_url: 'http://test.host').payload.deep_stringify_keys

    assert_equal true, payload.dig('users', 0, 'legal_acceptance_required')
    assert_nil @user.reload.legal_accepted_at
  end

  test "me returns unauthorized for visitors" do
    get :me, format: :json
    assert_response :unauthorized
  end

  test "avatar uploaded reports an available provider picture" do
    @user.identities.create!(identity_type: 'oauth', uid: 'profile-picture', logo: 'https://example.com/picture.png')
    sign_in @user

    get :avatar_uploaded, format: :json

    assert_response :success
    assert_equal({ 'provider' => 'OAUTH' }, JSON.parse(response.body).fetch('provider_picture'))
  end

  test "user can select an available provider picture" do
    @user.identities.create!(identity_type: 'oauth', uid: 'profile-picture', logo: 'https://example.com/picture.png')
    sign_in @user

    SafeHttpService.stub :safe_open, ->(_url) { File.open(Rails.root.join('public/brand/icon-yellow-on-white-192.png')) } do
      post :use_provider_avatar, format: :json
    end

    assert_response :success
    assert @user.reload.uploaded_avatar.attached?
    assert_equal 'uploaded', @user.avatar_kind
  end

  test "user cannot select a provider picture when profile editing is disabled" do
    @user.identities.create!(identity_type: 'oauth', uid: 'profile-picture', logo: 'https://example.com/picture.png')
    ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'] = '1'
    sign_in @user

    post :use_provider_avatar, format: :json

    assert_response :forbidden
  end

  test "provider picture cannot be selected when none is available" do
    sign_in @user

    post :use_provider_avatar, format: :json

    assert_response :not_found
  end

  test "restricted user cannot select a provider picture" do
    @user.identities.create!(identity_type: 'oauth', uid: 'profile-picture', logo: 'https://example.com/picture.png')
    @user.update_columns(unsubscribe_token: UNSUB)

    post :use_provider_avatar, params: { unsubscribe_token: UNSUB }, format: :json

    assert_response :forbidden
  end

  test "email and push defaults can be applied independently" do
    sign_in @user
    membership = @group.membership_for(@user)
    membership.update!(volume_email: :normal, volume_push: :loud)

    post :set_volume, params: { volume_email: :quiet, apply_to_all: true }

    assert_response :success
    assert_equal "quiet", @user.reload.volume_email_default
    assert_equal "quiet", membership.reload.volume_email
    assert_equal "loud", membership.volume_push

    post :set_volume, params: { volume_push: :normal, apply_to_all: true }

    assert_response :success
    assert_equal "normal", @user.reload.volume_push_default
    assert_equal "quiet", membership.reload.volume_email
    assert_equal "normal", membership.volume_push
  end

  test "groups includes the current user's notification volumes" do
    sign_in @user
    @group.add_member!(@user) unless @group.members.include?(@user)
    membership = @group.membership_for(@user)
    membership.update!(volume_email: :normal, volume_push: :loud)

    assert_no_record_cache_fallbacks do
      get :groups, format: :json
    end

    assert_response :success
    serialized_membership = JSON.parse(response.body).fetch("memberships").find do |attributes|
      attributes.fetch("id") == membership.id
    end
    assert_equal "normal", serialized_membership.fetch("volume_email")
    assert_equal "loud", serialized_membership.fetch("volume_push")
  end

  test "destroy deactivates the users account" do
    sign_in @user
    post :destroy, format: :json
    assert_response :success
    assert @user.reload.deactivated_at.present?
  end

  test "save_experience responds with unauthorized when user is logged out" do
    post :save_experience, params: { experience: :happiness }
    assert_response :unauthorized
  end

  test "save_experience responds with bad request when no experience is given" do
    sign_in @user
    post :save_experience
    assert_response :bad_request
  end

  test "contactable allows access for group members" do
    sign_in @user
    @group.add_member!(@user) unless @group.members.include?(@user)
    @group.add_member!(@alien) unless @group.members.include?(@alien)
    get :contactable, params: { user_id: @alien.id }
    assert_response :success
    assert_equal true, JSON.parse(response.body).fetch("contactable")
  end

  test "contactable reports false for unrelated users" do
    sign_in @user
    other_user = User.create!(name: "Other User", username: "otheruser1234", email: "other@example.com")
    get :contactable, params: { user_id: other_user.id }
    assert_response :success
    assert_equal false, JSON.parse(response.body).fetch("contactable")
  end

  test "contactable requires a signed in user" do
    get :contactable, params: { user_id: @alien.id }
    assert_response :unauthorized
  end

  test "contactable does not grant instance administrators access to unrelated users" do
    sign_in users(:admin)
    other_user = User.create!(name: "Unrelated User", username: "unrelateduser1234", email: "unrelated@example.com")
    get :contactable, params: { user_id: other_user.id }
    assert_response :success
    assert_equal false, JSON.parse(response.body).fetch("contactable")
  end

  test "updating password signs out other sessions" do
    sign_in @user
    original_api_key = @user.api_key
    original_email_api_key = @user.email_api_key
    original_secret_token = @user.secret_token
    original_unsubscribe_token = @user.unsubscribe_token
    current_session = Current.session
    other_session = @user.sessions.create!(user_agent: 'other browser', ip_address: '127.0.0.2')
    current_subscription = create_push_subscription(
      user: @user,
      session: current_session,
      endpoint: "https://fcm.googleapis.com/fcm/send/current-session-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    other_subscription = create_push_subscription(
      user: @user,
      session: other_session,
      endpoint: "https://fcm.googleapis.com/fcm/send/other-session-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )
    unused_login_token = @user.login_tokens.create!

    post :update_profile, params: {
      user: {
        password: 'new_complex_password',
        password_confirmation: 'new_complex_password'
      }
    }, format: :json

    assert_response :success
    @user.reload
    assert Session.exists?(current_session.id)
    refute Session.exists?(other_session.id)
    assert PushSubscription.exists?(current_subscription.id)
    refute PushSubscription.exists?(other_subscription.id)
    refute_equal original_api_key, @user.api_key
    refute_equal original_email_api_key, @user.email_api_key
    refute_equal original_secret_token, @user.secret_token
    refute_equal original_unsubscribe_token, @user.unsubscribe_token
    refute LoginToken.exists?(unused_login_token.id)
  end

  test "SSO-only mode does not register a local password" do
    ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = '1'
    sign_in @user
    original_digest = @user.password_digest

    post :update_profile, params: {
      user: {
        password: 'new_complex_password',
        password_confirmation: 'new_complex_password'
      }
    }

    assert_response :success
    assert_equal original_digest, @user.reload.password_digest
  end

  # -- unsubscribe-token (restricted user) authorization --
  # An attacker who obtains a victim's permanent unsubscribe_token (present in
  # the footer of every notification email) must not be able to take over or
  # destroy the account. These prove the restricted-user guardrails.

  UNSUB = 'unsub-secret-token-for-tests'

  test "restricted user cannot change password via update_profile" do
    @user.update_columns(unsubscribe_token: UNSUB)
    original_digest = @user.password_digest

    post :update_profile, params: {
      unsubscribe_token: UNSUB,
      user: { password: 'attacker_password_123', password_confirmation: 'attacker_password_123' }
    }, format: :json

    assert_equal original_digest, @user.reload.password_digest, "restricted user must not change password"
  end

  test "restricted user cannot change email via update_profile" do
    @user.update_columns(unsubscribe_token: UNSUB)
    original_email = @user.email

    post :update_profile, params: {
      unsubscribe_token: UNSUB,
      user: { email: 'attacker@evil.test' }
    }, format: :json

    assert_equal original_email, @user.reload.email, "restricted user must not change email"
  end

  test "profile update cannot change email before confirmation" do
    sign_in @user
    original_email = @user.email

    post :update_profile, params: {user: {email: 'unconfirmed@example.com'}}, format: :json

    assert_response :unprocessable_entity
    assert_equal original_email, @user.reload.email
    assert_nil @user.email_change_pending
  end

  test "requesting an email change keeps the current address and queues confirmation" do
    sign_in @user
    original_email = @user.email

    assert_difference 'enqueued_jobs.count', 2 do
      post :request_email_change, params: {email: 'new-profile@example.com'}, format: :json
    end

    assert_response :success
    assert_equal original_email, @user.reload.email
    assert_equal 'new-profile@example.com', @user.email_change_pending
    assert_equal 'new-profile@example.com', JSON.parse(response.body).fetch('users').first.fetch('email_change_pending')
  end

  test "restricted user cannot request an email change" do
    @user.update_columns(unsubscribe_token: UNSUB)

    post :request_email_change, params: {unsubscribe_token: UNSUB, email: 'new-profile@example.com'}, format: :json

    assert_response :forbidden
    assert_nil @user.reload.email_change_pending
  end

  test "profile editing restriction also blocks email changes" do
    ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'] = '1'
    sign_in @user

    post :request_email_change, params: {email: 'new-profile@example.com'}, format: :json

    assert_response :forbidden
    assert_nil @user.reload.email_change_pending
  end

  test "restricted user cannot deactivate the account" do
    @user.update_columns(unsubscribe_token: UNSUB, deactivated_at: nil)

    post :deactivate, params: { unsubscribe_token: UNSUB }, format: :json

    assert_response :forbidden
    assert_nil @user.reload.deactivated_at
  end

  test "restricted user cannot redact/destroy the account" do
    @user.update_columns(unsubscribe_token: UNSUB)

    delete :destroy, params: { unsubscribe_token: UNSUB }, format: :json

    assert_response :forbidden
  end

  test "restricted user cannot read the email_api_key" do
    @user.update_columns(unsubscribe_token: UNSUB)

    get :email_api_key, params: { unsubscribe_token: UNSUB }, format: :json

    assert_response :forbidden
  end

  test "restricted user cannot reset the email_api_key" do
    @user.update_columns(unsubscribe_token: UNSUB)
    original = @user.email_api_key

    post :reset_email_api_key, params: { unsubscribe_token: UNSUB }, format: :json

    assert_response :forbidden
    assert_equal original, @user.reload.email_api_key
  end

  test "merge verification has the same response whether the email belongs to an account" do
    sign_in @user
    target = User.create!(email: "merge-target@example.com", email_verified: true)

    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      post :send_merge_verification_email, params: { target_email: target.email }, format: :json
    end
    existing_response = response.body
    assert_response :success

    assert_no_difference "ActionMailer::Base.deliveries.count" do
      post :send_merge_verification_email, params: { target_email: "missing-merge@example.com" }, format: :json
    end
    assert_response :success
    assert_equal existing_response, response.body
  end

  test "restricted user CAN still update notification preferences" do
    @user.update_columns(
      unsubscribe_token: UNSUB,
      volume_email_default: User.volume_email_defaults[:quiet],
      volume_push_default: User.volume_push_defaults[:quiet]
    )

    post :update_profile, params: {
      unsubscribe_token: UNSUB,
      user: { volume_email_default: "normal", volume_push_default: "normal" }
    }, format: :json

    assert_response :success
    assert_predicate @user.reload, :email_default_normal?
    assert_predicate @user, :push_default_normal?
  end
end
