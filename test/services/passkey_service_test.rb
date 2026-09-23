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

    PasskeyService.issue_challenge!(browser_session, PasskeyService::CHALLENGE_AUTHENTICATION, SecureRandom.urlsafe_base64(32))

    assert_not PasskeyChallenge.exists?(previous_id)
  end
end
