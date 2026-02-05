require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "signs in with password" do
    user = User.create!(
      email: "sessionsuser@example.com",
      email_verified: true,
      password: "s3curepassword123"
    )
    
    post :create, params: { user: { email: "sessionsuser@example.com", password: "s3curepassword123" } }
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "does not sign in a blank password" do
    User.create!(email: "sessionsuser2@example.com", email_verified: true)
    
    post :create, params: { user: { email: "sessionsuser2@example.com", password: "" } }
    assert_response :unauthorized
  end

  test "does not sign in a nil password" do
    User.create!(email: "sessionsuser3@example.com", email_verified: true)
    
    post :create, params: { user: { email: "sessionsuser3@example.com", password: nil } }
    assert_response :unauthorized
  end

  test "signs in a user via token" do
    user = User.create!(email: "tokenuser@example.com", email_verified: true)
    token = LoginToken.create!(user: user)
    session[:pending_login_token] = token.token
    
    post :create
    assert token.reload.used
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "does not sign in a user with a used token" do
    user = User.create!(email: "usedtoken@example.com", email_verified: true)
    token = LoginToken.create!(user: user, used: true)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :unauthorized
  end

  test "does not sign in a user with an expired token" do
    user = User.create!(email: "expiredtoken@example.com", email_verified: true)
    token = LoginToken.create!(user: user, created_at: 25.hours.ago)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :unauthorized
  end

  test "does not sign in a user with an invalid token id" do
    session[:pending_login_token] = 'notatoken'
    
    post :create
    assert_response :unauthorized
  end

  test "finds a verified user to sign in" do
    user = User.create!(email: "verified@example.com", email_verified: true)
    User.create!(email: "unverified@example.com", email_verified: false)
    token = LoginToken.create!(user: user)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal user.id, json['current_user_id']
  end

  test "signs in an unverified user" do
    unverified_user = User.create!(email: "unverified2@example.com", email_verified: false)
    token = LoginToken.create!(user: unverified_user)
    session[:pending_login_token] = token.token
    
    post :create
    assert_response :success
    
    json = JSON.parse(response.body)
    assert_equal unverified_user.id, json['current_user_id']
  end
end
