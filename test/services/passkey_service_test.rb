require 'test_helper'

class PasskeyServiceTest < ActiveSupport::TestCase
  test "a challenge is consumed once even when its cookie payload is restored" do
    browser_session = {}
    challenge = SecureRandom.urlsafe_base64(32)
    PasskeyService.issue_challenge!(browser_session, PasskeyService::CHALLENGE_AUTHENTICATION, challenge)
    saved_payload = browser_session.deep_dup

    assert_equal challenge, PasskeyService.consume_challenge!(browser_session, PasskeyService::CHALLENGE_AUTHENTICATION)
    assert_raises(WebAuthn::Error) do
      PasskeyService.consume_challenge!(saved_payload, PasskeyService::CHALLENGE_AUTHENTICATION)
    end
  end

  test "a registration challenge is bound to its ceremony and user" do
    browser_session = {}
    challenge = SecureRandom.urlsafe_base64(32)
    user = users(:user)
    other_user = users(:admin)
    PasskeyService.issue_challenge!(browser_session, PasskeyService::CHALLENGE_REGISTRATION, challenge, user: user)
    saved_payload = browser_session.deep_dup

    assert_raises(WebAuthn::Error) do
      PasskeyService.consume_challenge!(browser_session, PasskeyService::CHALLENGE_REGISTRATION, user: other_user)
    end
    assert_raises(WebAuthn::Error) do
      PasskeyService.consume_challenge!(saved_payload, PasskeyService::CHALLENGE_AUTHENTICATION, user: user)
    end
  end

  test "issuing a replacement deletes the earlier server-side challenge" do
    browser_session = {}
    PasskeyService.issue_challenge!(browser_session, PasskeyService::CHALLENGE_AUTHENTICATION, SecureRandom.urlsafe_base64(32))
    previous_id = browser_session.dig(PasskeyService::CHALLENGE_AUTHENTICATION, :challenge_id)
    other_browser = {}
    PasskeyService.issue_challenge!(other_browser, PasskeyService::CHALLENGE_AUTHENTICATION, SecureRandom.urlsafe_base64(32))
    expired_id = other_browser.dig(PasskeyService::CHALLENGE_AUTHENTICATION, :challenge_id)
    PasskeyChallenge.find(expired_id).update!(expires_at: 1.second.ago)

    PasskeyService.issue_challenge!(browser_session, PasskeyService::CHALLENGE_AUTHENTICATION, SecureRandom.urlsafe_base64(32))

    assert_not PasskeyChallenge.exists?(previous_id)
    assert_not PasskeyChallenge.exists?(expired_id)
  end

  test "further registrations reuse the persisted WebAuthn account handle" do
    user = users(:member_normal)
    handle = PasskeyService.ensure_webauthn_id!(user)

    assert_predicate handle, :present?
    assert_equal handle, user.reload.webauthn_id
    assert_equal handle, PasskeyService.ensure_webauthn_id!(User.find(user.id))
    assert_equal handle, user.reload.webauthn_id
  end

  test "recent authentication includes the exact cutoff and expires afterward" do
    freeze_time do
      session_record = users(:member_normal).sessions.create!(created_at: PasskeyService::RECENT_AUTHENTICATION_TTL.ago)

      assert PasskeyService.recently_authenticated?(session_record)
      travel 1.second
      assert_not PasskeyService.recently_authenticated?(session_record)
    end
  end
end
