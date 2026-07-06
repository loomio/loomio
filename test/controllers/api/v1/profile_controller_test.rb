require 'test_helper'

class Api::V1::ProfileControllerTest < ActionController::TestCase
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

  test "groups uses record cache for serialized associations" do
    sign_in @user
    @group.add_member!(@user) unless @group.members.include?(@user)

    assert_no_record_cache_fallbacks do
      get :groups, format: :json
    end

    assert_response :success
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
    refute_equal original_api_key, @user.api_key
    refute_equal original_email_api_key, @user.email_api_key
    refute_equal original_secret_token, @user.secret_token
    refute_equal original_unsubscribe_token, @user.unsubscribe_token
    refute LoginToken.exists?(unused_login_token.id)
  end
end
