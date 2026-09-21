require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @original_turnstile_secret = ENV['TURNSTILE_SECRET_KEY']
    @disable_local_login_before = ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN')
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_turnstile_secret
    @disable_local_login_before.nil? ? ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN') : ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = @disable_local_login_before
  end

  test "turnstile required: rejects registration without token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    assert_no_difference 'User.count' do
      post :create, params: { user: { email: "cfblock@example.com" } }
    end
    assert_response :forbidden
  end

  test "SSO-only mode rejects native account creation" do
    ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = '1'

    assert_no_difference "User.count" do
      post :create, params: { user: { email: "local@example.com" } }
    end
    assert_response :forbidden
  end

  test "turnstile required: accepts registration with valid token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    assert_difference 'User.count', 1 do
      post :create, params: { user: { email: "cfok@example.com" }, turnstile_token: "cf-ok" }
    end
    assert_response :success
  end

  test "turnstile bypass: pending_membership skips the challenge" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    # If Turnstile were consulted we'd need to stub siteverify. Asserting success without a
    # stub proves the email-verified bypass takes the pending_membership path.
    pending_membership = Membership.create!(
      user: User.create(email: "bypass@example.com", email_verified: false),
      group: groups(:group),
      accepted_at: nil
    )
    session[:pending_membership_token] = pending_membership.token

    post :create, params: { user: { email: "bypass@example.com" } }
    assert_response :success
  end

  test "creates a new user" do
    assert_difference 'User.count', 1 do
      post :create, params: {
        user: { email: "jon@snow.com" }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u = User.find_by(email: "jon@snow.com")
    assert_nil u.name
    assert_equal "jon@snow.com", u.email
    assert_nil u.legal_accepted_at
  end

  test "creates a new user with an invalid referrer" do
    request.env['HTTP_REFERER'] = 'http://%zz'

    assert_difference 'User.count', 1 do
      post :create, params: {
        user: { email: "bad-referrer@example.com" }
      }
    end

    assert_response :success
  end

  test "sign up via email for existing user (email_verified = false)" do
    u = User.create(email: "jon@snow.com", email_verified: false)

    assert_difference 'User.count', 0 do
      post :create, params: {
        user: { email: "jon@snow.com" }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u.reload
    assert_nil u.name
    assert_nil u.legal_accepted_at
  end

  test "sign up via email for existing user (email_verified = true)" do
    u = User.create(email: "jon@snow.com", email_verified: true)

    post :create, params: {
      user: { email: "jon@snow.com" }
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']
    assert_equal 1, u.login_tokens.count
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
        user: { email: "jon@snow.com" }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json['signed_in']
    assert_equal I18n.t('auth_form.signed_in'), json.dig('flash', 'notice')

    u = User.find_by(email: "jon@snow.com")
    assert_nil u.name
    assert_nil u.legal_accepted_at
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
        user: { email: "changed@example.com" }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u = User.find_by(email: "changed@example.com")
    assert_nil u.name
    assert_nil u.legal_accepted_at
  end

  test "signup via discussion invitation verifies and redeems the invited account" do
    invited_user = User.create!(email: "discussion-guest@example.com", email_verified: false)
    reader = TopicReader.create!(
      topic: topics(:discussion_topic),
      user: invited_user,
      guest: true,
      inviter: users(:admin)
    )

    post :create, params: {
      topic_reader_token: reader.token,
      user: { email: invited_user.email }
    }

    assert_response :success
    assert_equal true, JSON.parse(response.body)['signed_in']
    assert invited_user.reload.email_verified?
    assert_not_nil reader.reload.accepted_at
  end

  test "discussion invitation does not verify a different signup email" do
    invited_user = User.create!(email: "discussion-invite@example.com", email_verified: false)
    reader = TopicReader.create!(
      topic: topics(:discussion_topic),
      user: invited_user,
      guest: true,
      inviter: users(:admin)
    )

    post :create, params: {
      topic_reader_token: reader.token,
      user: { email: "different-discussion-user@example.com" }
    }

    assert_response :success
    assert_equal false, JSON.parse(response.body)['signed_in']
    assert_not User.find_by!(email: "different-discussion-user@example.com").email_verified?
    assert_nil reader.reload.accepted_at
    assert_equal invited_user, reader.user
  end

  test "signup via vote invitation verifies the invited account and retains its stance" do
    invited_user = User.create!(email: "vote-guest@example.com", email_verified: false)
    stance = Stance.create!(
      poll: invitation_poll,
      participant: invited_user,
      inviter: users(:admin)
    )

    post :create, params: {
      stance_token: stance.token,
      user: { email: invited_user.email }
    }

    assert_response :success
    assert_equal true, JSON.parse(response.body)['signed_in']
    assert invited_user.reload.email_verified?
    assert_equal invited_user, stance.reload.participant
    assert_not Stance.redeemable_by(users(:user)).exists?(stance.id)
  end

  test "vote invitation does not verify a different signup email" do
    invited_user = User.create!(email: "vote-invite@example.com", email_verified: false)
    stance = Stance.create!(
      poll: invitation_poll,
      participant: invited_user,
      inviter: users(:admin)
    )

    post :create, params: {
      stance_token: stance.token,
      user: { email: "different-voter@example.com" }
    }

    assert_response :success
    assert_equal false, JSON.parse(response.body)['signed_in']
    assert_not User.find_by!(email: "different-voter@example.com").email_verified?
    assert_nil stance.reload.accepted_at
    assert_equal invited_user, stance.participant
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
        user: { email: "newuser@example.com" }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal false, json['signed_in']

    u = User.find_by(email: "newuser@example.com")
    assert_nil u.name
    assert_nil u.legal_accepted_at
  end

  test "signup via login token" do
    login_user = User.create(email: "jon@snow.com", email_verified: false)
    login_token = LoginToken.create(user: login_user)
    session[:pending_login_token] = login_token.token

    assert_difference 'User.count', 0 do
      post :create, params: {
        user: { email: "jon@snow.com" }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal true, json['signed_in']
    assert_equal I18n.t('auth_form.signed_in'), json.dig('flash', 'notice')

    u = User.find_by(email: "jon@snow.com")
    assert_nil u.name
    assert_nil u.legal_accepted_at
  end

  test "turnstile bypass: expired login token is not accepted" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    login_user = User.create(email: "expiredsignup@example.com", email_verified: false)
    login_token = LoginToken.create(user: login_user, created_at: 25.hours.ago)
    session[:pending_login_token] = login_token.token

    post :create, params: {
      user: { email: "expiredsignup@example.com" }
    }

    assert_response :forbidden
  end

  test "turnstile bypass: used login token is not accepted" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    login_user = User.create(email: "usedsignup@example.com", email_verified: false)
    login_token = LoginToken.create(user: login_user, used: true)
    session[:pending_login_token] = login_token.token

    post :create, params: {
      user: { email: "usedsignup@example.com" }
    }

    assert_response :forbidden
  end

  test "defers name and legal acceptance until the verified user completes their account" do
    post :create, params: {
      user: { email: "jon@snow.com" }
    }

    assert_response :success
    user = User.find_by!(email: "jon@snow.com")
    assert_nil user.name
    assert_nil user.legal_accepted_at
  end

  private

  def invitation_poll
    @invitation_poll ||= PollService.create(
      params: {
        title: "Invitation poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        poll_option_names: ["Agree", "Disagree"],
        topic_id: topics(:discussion_topic).id
      },
      actor: users(:admin)
    )
  end
end
