require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @original_turnstile_secret = ENV['TURNSTILE_SECRET_KEY']
    @disable_local_login_before = ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN')
    @disable_create_user_before = ENV.delete('FEATURES_DISABLE_CREATE_USER')
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_turnstile_secret
    @disable_local_login_before.nil? ? ENV.delete('FEATURES_DISABLE_LOCAL_LOGIN') : ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = @disable_local_login_before
    @disable_create_user_before.nil? ? ENV.delete('FEATURES_DISABLE_CREATE_USER') : ENV['FEATURES_DISABLE_CREATE_USER'] = @disable_create_user_before
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

  test "turnstile required: rejects an invalid token" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: false }.to_json, headers: { 'Content-Type' => 'application/json' })

    assert_no_difference 'User.count' do
      post :create, params: { user: { email: "cf-invalid@example.com", turnstile_token: "cf-invalid" } }
    end

    assert_response :forbidden
  end

  test "registration requires an invitation when public account creation is disabled" do
    ENV['FEATURES_DISABLE_CREATE_USER'] = '1'

    assert_no_difference 'User.count' do
      post :create, params: { user: { email: "invitation-required@example.com" } }
    end

    assert_response :unprocessable_entity
    assert_equal [ 'email' ], JSON.parse(response.body).fetch('errors').keys
  end

  test "an invitation permits registration when public account creation is disabled" do
    ENV['FEATURES_DISABLE_CREATE_USER'] = '1'
    membership = pending_membership_for("invited-registration@example.com")

    post :create, params: { membership_token: membership.token, user: { email: membership.user.email } }

    assert_response :success
    assert_equal true, JSON.parse(response.body)['incomplete']
  end

  test "a pending group permits code registration when public account creation is disabled" do
    ENV['FEATURES_DISABLE_CREATE_USER'] = '1'
    session[:pending_group_token] = groups(:group).token

    assert_difference [ 'User.count', 'LoginToken.count' ], 1 do
      post :create, params: { user: { email: "pending-group@example.com" } }
    end

    assert_response :success
    assert_equal false, JSON.parse(response.body)['signed_in']
  end

  test "an invitation does not bypass the Turnstile challenge" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    membership = pending_membership_for("invitation-turnstile@example.com")

    post :create, params: { membership_token: membership.token, user: { email: membership.user.email } }

    assert_response :forbidden
    assert_not AccountCompletionProof.exists?(user: membership.user)
  end

  test "an invitation proves email ownership after Turnstile succeeds" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    membership = pending_membership_for("invitation-turnstile-success@example.com")

    assert_no_difference 'LoginToken.count' do
      post :create, params: {
        membership_token: membership.token,
        user: { email: membership.user.email, turnstile_token: "cf-ok" }
      }
    end

    assert_response :success
    assert_equal true, response.parsed_body['incomplete']
    assert AccountCompletionProof.exists?(user: membership.user)
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

  test "normalizes a new registration email" do
    post :create, params: { user: { email: "  Mixed.Case@Example.COM  " } }

    assert_response :success
    assert_equal "mixed.case@example.com", User.find_by!(email: "mixed.case@example.com").email
  end

  test "returns validation errors without sending a code" do
    assert_no_difference [ 'User.count', 'LoginToken.count', 'ActionMailer::Base.deliveries.count' ] do
      post :create, params: { user: { email: "not an email" } }
    end

    assert_response :unprocessable_entity
    assert JSON.parse(response.body).dig('errors', 'email').present?
  end

  test "completes an authenticated pending account before creating its session" do
    user = User.create!(email: "complete-account@example.com", email_verified: false)
    @controller.stage_account_completion(user)

    assert_difference "Session.count", 1 do
      post :complete, params: { user: { name: "Complete Person", legal_accepted: true, email_newsletter: true } }
    end

    assert_response :success
    assert_equal user.id, JSON.parse(response.body)['current_user_id']
    assert user.reload.email_verified?
    assert_equal "Complete Person", user.name
    assert user.email_newsletter?
    assert_nil session[:pending_account_completion]
  end

  test "does not complete an account without a pending authentication" do
    user = User.create!(email: "unstaged-account@example.com", email_verified: false)

    assert_no_difference "Session.count" do
      post :complete, params: { user: { name: "Unstaged Person", legal_accepted: true } }
    end

    assert_response :unauthorized
    assert_nil user.reload.name
  end

  test "does not complete an account after the pending authentication expires" do
    user = User.create!(email: "expired-completion@example.com", email_verified: false)
    @controller.stage_account_completion(user)
    @controller.pending_account_completion_proof.update!(expires_at: Time.current)

    assert_no_difference "Session.count" do
      post :complete, params: { user: { name: "Expired Person", legal_accepted: true } }
    end

    assert_response :unauthorized
    assert_nil user.reload.name
  end

  test "legacy cookie-only completion state cannot create a session" do
    user = User.create!(email: "legacy-completion@example.com", email_verified: false)
    session[:pending_account_completion] = { user_id: user.id, authenticated_at: Time.current.to_i }

    assert_no_difference "Session.count" do
      post :complete, params: { user: { name: "Legacy Person", legal_accepted: true } }
    end
    assert_response :unauthorized
    assert_nil user.reload.name
  end

  test "does not accept a client-supplied name for an SSO-managed account" do
    user = User.create!(email: "managed-name@example.com", name: "Provider Name", email_verified: true)
    @controller.stage_account_completion(user, name_managed: true)

    post :complete, params: { user: { name: "Changed Name", legal_accepted: true } }

    assert_response :success
    assert_equal "Provider Name", user.reload.name
    assert_not_nil user.legal_accepted_at
  end

  test "SSO-only mode permits completion of an SSO-authenticated account" do
    ENV['FEATURES_DISABLE_LOCAL_LOGIN'] = '1'
    user = User.create!(email: "sso-completion@example.com", name: "SSO Person", email_verified: true)
    @controller.stage_account_completion(user, name_managed: true)

    assert_difference "Session.count", 1 do
      post :complete, params: { user: { name: "Injected Name", legal_accepted: true } }
    end

    assert_response :success
    assert_equal "SSO Person", user.reload.name
    assert_not_nil user.legal_accepted_at
  end

  test "completion returns the protected authentication destination" do
    user = User.create!(email: "completion-return@example.com", email_verified: true)
    @controller.stage_account_completion(user)
    session[:return_to_after_authenticating] = "/d/return-here"

    post :complete, params: { user: { name: "Returning Person", legal_accepted: true } }

    assert_response :success
    assert_equal "/d/return-here", JSON.parse(response.body)['authentication_redirect']
  end

  test "completion rolls back profile changes when session creation fails" do
    user = User.create!(email: "completion-rollback@example.com", email_verified: true)
    @controller.stage_account_completion(user)
    proof = @controller.pending_account_completion_proof

    @controller.stub(:start_new_session_for, ->(_) { raise ActiveRecord::StatementInvalid, "session failure" }) do
      assert_raises ActiveRecord::StatementInvalid do
        post :complete, params: { user: { name: "Should Roll Back", legal_accepted: true } }
      end
    end

    assert_nil user.reload.name
    assert_nil user.legal_accepted_at
    assert_equal user.id, session.dig(:pending_account_completion, :user_id)
    assert AccountCompletionProof.exists?(proof.id)
    post :complete, params: { user: { name: "Retry Person", legal_accepted: true } }
    assert_response :success
    assert_not AccountCompletionProof.exists?(proof.id)
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

  test "returns the generic success response for a deactivated existing account without sending mail" do
    user = User.create!(email: "deactivated@example.com", name: "Deactivated", email_verified: true, deactivated_at: Time.current)

    assert_no_difference [ 'LoginToken.count', 'ActionMailer::Base.deliveries.count' ] do
      post :create, params: { user: { email: user.email } }
    end

    assert_response :success
    assert_equal({ 'success' => 'ok', 'signed_in' => false }, JSON.parse(response.body))
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
    assert_equal false, json['signed_in']
    assert_equal true, json['incomplete']
    complete_pending_account

    u = User.find_by(email: "jon@snow.com")
    assert_equal "New Person", u.name
    assert_not_nil u.legal_accepted_at
  end

  test "signup proof compares email addresses case-insensitively" do
    membership = pending_membership_for("case-proof@example.com")

    post :create, params: { membership_token: membership.token, user: { email: "CASE-PROOF@EXAMPLE.COM" } }

    assert_response :success
    assert_equal true, JSON.parse(response.body)['incomplete']
  end

  test "a request invitation replaces a stale invitation of the same type" do
    stale_membership = pending_membership_for("stale@example.com")
    selected_membership = pending_membership_for("selected@example.com")
    session[:pending_membership_token] = stale_membership.token

    post :create, params: { membership_token: selected_membership.token, user: { email: selected_membership.user.email } }
    assert_response :success
    assert_equal selected_membership.token, session[:pending_membership_token]

    complete_pending_account
    assert_nil stale_membership.reload.accepted_at
    assert_not_nil selected_membership.reload.accepted_at
  end

  test "a matching invitation is selected when another invitation type is stale" do
    stale_membership = pending_membership_for("stale-other-type@example.com")
    invited_user = User.create!(email: "selected-reader@example.com", email_verified: false)
    reader = TopicReader.create!(topic: topics(:discussion_topic), user: invited_user, guest: true, inviter: users(:admin))
    session[:pending_membership_token] = stale_membership.token

    post :create, params: { topic_reader_token: reader.token, user: { email: invited_user.email } }
    assert_response :success
    assert_nil session[:pending_membership_token]
    assert_equal reader.token, session[:pending_topic_reader_token]

    complete_pending_account
    assert_nil stale_membership.reload.accepted_at
    assert_not_nil reader.reload.accepted_at
  end

  test "a request invitation takes precedence over a stale login token" do
    stale_user = User.create!(email: "stale-login@example.com", email_verified: false)
    stale_token = LoginToken.create!(user: stale_user)
    session[:pending_login_token] = stale_token.token
    invited_user = User.create!(email: "requested-reader@example.com", email_verified: false)
    reader = TopicReader.create!(topic: topics(:discussion_topic), user: invited_user, guest: true, inviter: users(:admin))

    post :create, params: { topic_reader_token: reader.token, user: { email: invited_user.email } }

    assert_response :success
    assert_nil session[:pending_login_token]
    assert_equal reader.token, session[:pending_topic_reader_token]
    complete_pending_account
    assert_not stale_token.reload.used?
    assert_not_nil reader.reload.accepted_at
  end

  test "a proved account that is already complete signs in without account completion" do
    user = User.create!(email: "complete-invite@example.com", name: "Complete Invite", email_verified: false, legal_accepted_at: Time.current)
    membership = Membership.create!(user: user, group: groups(:group), accepted_at: nil)

    assert_difference 'Session.count', 1 do
      post :create, params: { membership_token: membership.token, user: { email: user.email } }
    end

    assert_response :success
    assert_equal true, JSON.parse(response.body)['signed_in']
    assert user.reload.email_verified?
    assert_not_nil membership.reload.accepted_at
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
    assert_equal true, JSON.parse(response.body)['incomplete']
    complete_pending_account
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
    assert_equal true, JSON.parse(response.body)['incomplete']
    complete_pending_account
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
    assert_equal false, json['signed_in']
    assert_equal true, json['incomplete']
    complete_pending_account

    u = User.find_by(email: "jon@snow.com")
    assert_equal "New Person", u.name
    assert_not_nil u.legal_accepted_at
  end

  test "signup via an SSO identity proves the identity email" do
    identity_user = User.create!(email: "identity-registration@example.com", email_verified: false)
    identity = Identity.create!(
      identity_type: "oauth",
      uid: "registration-identity",
      email: identity_user.email,
      user: identity_user
    )
    session[:pending_identity_id] = identity.id

    post :create, params: { user: { email: identity_user.email } }

    assert_response :success
    assert_equal true, JSON.parse(response.body)['incomplete']
    complete_pending_account
    assert identity_user.reload.email_verified?
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

  def pending_membership_for(email)
    Membership.create!(
      user: User.create!(email: email, email_verified: false),
      group: groups(:group),
      accepted_at: nil
    )
  end

  def complete_pending_account
    post :complete, params: { user: { name: "New Person", legal_accepted: true } }
    assert_response :success
  end

  def invitation_poll
    @invitation_poll ||= PollService.create(
      params: {
        title: "Invitation poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        poll_option_names: [ "Agree", "Disagree" ],
        topic_id: topics(:discussion_topic).id
      },
      actor: users(:admin)
    )
  end
end
