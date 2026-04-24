require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    request.env['devise.mapping'] = Devise.mappings[:user]
    @original_turnstile_secret = ENV['TURNSTILE_SECRET_KEY']
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_turnstile_secret
  end

  test "turnstile required: rejects registration without token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    assert_no_difference 'User.count' do
      post :create, params: { user: { name: "Cf Block", email: "cfblock@example.com", legal_accepted: true } }
    end
    assert_response :forbidden
  end

  test "turnstile required: accepts registration with valid token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    assert_difference 'User.count', 1 do
      post :create, params: { user: { name: "Cf Ok", email: "cfok@example.com", legal_accepted: true }, turnstile_token: "cf-ok" }
    end
    assert_response :success
  end

  test "turnstile bypass: pending_membership skips the challenge" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    # If Turnstile were consulted we'd need to stub siteverify. Asserting success without a
    # stub proves the email-verified bypass takes the pending_membership path.
    pending_membership = Membership.create!(
      user: User.create(email: "bypass@example.com", email_verified: false),
      group: groups(:test_group),
      accepted_at: nil
    )
    session[:pending_membership_token] = pending_membership.token

    post :create, params: { user: { name: "Bypass", email: "bypass@example.com", legal_accepted: true } }
    assert_response :success
  end

  test "creates a new user" do
    assert_difference 'User.count', 1 do
      post :create, params: {
        user: {
          name: "Jon Snow",
          email: "jon@snow.com",
          legal_accepted: true
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u = User.find_by(email: "jon@snow.com")
    assert_equal "Jon Snow", u.name
    assert_equal "jon@snow.com", u.email
    assert u.legal_accepted_at.present?
  end

  test "sign up via email for existing user (email_verified = false)" do
    u = User.create(email: "jon@snow.com", email_verified: false)

    assert_difference 'User.count', 0 do
      post :create, params: {
        user: {
          name: "Jon Snow",
          email: "jon@snow.com",
          legal_accepted: true
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u.reload
    assert_equal "Jon Snow", u.name
    assert u.legal_accepted_at.present?
  end

  test "sign up via email for existing user (email_verified = true)" do
    u = User.create(email: "jon@snow.com", email_verified: true)

    post :create, params: {
      user: {
        name: "Jon Snow",
        email: "jon@snow.com",
        legal_accepted: true
      }
    }

    assert_response 422
    json = JSON.parse(response.body)
    assert_equal 'Email address is already registered', json['errors']['email'][0]
  end

  test "signup via membership" do
    pending_membership = Membership.create!(
      user: User.create(email: "jon@snow.com", email_verified: false),
      group: groups(:group),
      accepted_at: nil
    )
    session[:pending_membership_token] = pending_membership.token

    assert_difference 'User.count', 0 do
      post :create, params: {
        user: {
          name: "Jon Snow",
          email: "jon@snow.com",
          legal_accepted: true
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json['signed_in']

    u = User.find_by(email: "jon@snow.com")
    assert_equal "Jon Snow", u.name
    assert u.legal_accepted_at.present?
  end

  test "signup via membership with different email address" do
    pending_membership = Membership.create!(
      user: User.create(email: "jon@snow.com", email_verified: false),
      group: groups(:group),
      accepted_at: nil
    )
    session[:pending_membership_token] = pending_membership.token

    assert_difference 'User.count', 1 do
      post :create, params: {
        user: {
          name: "Jon Snow",
          email: "changed@example.com",
          legal_accepted: true
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u = User.find_by(email: "changed@example.com")
    assert_equal "Jon Snow", u.name
    assert u.legal_accepted_at.present?
  end

  test "signup via membership of another user" do
    other_user = User.create(email: "other@example.com", email_verified: true)
    pending_membership = Membership.create!(
      user: other_user,
      group: groups(:group),
      accepted_at: nil
    )
    session[:pending_membership_token] = pending_membership.token

    assert_difference 'User.count', 1 do
      post :create, params: {
        user: {
          name: "Jon Snow",
          email: "newuser@example.com",
          legal_accepted: true
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u = User.find_by(email: "newuser@example.com")
    assert_equal "Jon Snow", u.name
    assert u.legal_accepted_at.present?
  end

  test "signup via login token" do
    login_user = User.create(email: "jon@snow.com", email_verified: false)
    login_token = LoginToken.create(user: login_user)
    session[:pending_login_token] = login_token.token

    assert_difference 'User.count', 0 do
      post :create, params: {
        user: {
          name: "Jon Snow",
          email: "jon@snow.com",
          legal_accepted: true
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json['signed_in']

    u = User.find_by(email: "jon@snow.com")
    assert_equal "Jon Snow", u.name
    assert u.legal_accepted_at.present?
  end

  test "requires acceptance of legal" do
    post :create, params: {
      user: {
        name: "Jon Snow",
        email: "jon@snow.com"
      }
    }

    assert_response 422
  end
end
