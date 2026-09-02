require 'test_helper'

class Api::V1::ProfileControllerTest < ActionController::TestCase
  inline_jobs "destroy deactivates the users account"
  setup do
    @user = users(:user)
    @alien = users(:alien)
    @group = groups(:group)
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

  test "me returns unauthorized for visitors" do
    get :me, format: :json
    assert_response :unauthorized
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
  end

  test "contactable denies access for unrelated users" do
    sign_in @user
    other_user = User.create!(name: "Other User", username: "otheruser1234", email: "other@example.com")
    get :contactable, params: { user_id: other_user.id }
    assert_response :forbidden
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
