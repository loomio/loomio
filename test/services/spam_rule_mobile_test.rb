require 'test_helper'

class SpamRuleMobileTest < ActiveSupport::TestCase
  test 'existing mobile access and refresh tokens cannot bypass an email ban' do
    user = users(:user)
    verifier = 'v' * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    code = Mobile::AuthenticationService.issue_authorization_code!(user: user, client: Mobile::Client::IOS,
      redirect_uri: Mobile::Client::IOS_REDIRECT_URI, code_challenge: challenge)
    pair = Mobile::AuthenticationService.exchange_authorization_code!(code: code, code_verifier: verifier,
      client_id: Mobile::Client::IOS.id, redirect_uri: Mobile::Client::IOS_REDIRECT_URI, device_name: 'Test device')
    rule = SpamRule.create!(kind: 'email_domain', pattern: user.email.split('@').last)
    assert_raises(SpamRules::Denied) { Mobile::AuthenticationService.authenticate_access_token(pair[:access_token]) }
    assert_no_difference [ 'MobileAccessToken.count', 'MobileRefreshToken.count' ] do
      assert_raises(SpamRules::Denied) do
        Mobile::AuthenticationService.refresh!(refresh_token: pair[:refresh_token], client_id: Mobile::Client::IOS.id)
      end
    end
    rule.discard!
    assert Mobile::AuthenticationService.authenticate_access_token(pair[:access_token])
  end

  test 'an email ban prevents exchanging an existing authorization code without consuming it' do
    user = users(:user)
    verifier = 'v' * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    code = Mobile::AuthenticationService.issue_authorization_code!(user: user, client: Mobile::Client::IOS,
      redirect_uri: Mobile::Client::IOS_REDIRECT_URI, code_challenge: challenge)
    SpamRule.create!(kind: 'email_domain', pattern: user.email.split('@').last)
    assert_raises(SpamRules::Denied) do
      Mobile::AuthenticationService.exchange_authorization_code!(code: code, code_verifier: verifier,
        client_id: Mobile::Client::IOS.id, redirect_uri: Mobile::Client::IOS_REDIRECT_URI, device_name: 'Test device')
    end
    assert_nil MobileAuthorizationCode.find_by!(user: user).used_at
    assert_not MobileDevice.exists?(user: user)
  end

  test 'refresh reuse detection still revokes a compromised device while its email is banned' do
    user = users(:user)
    verifier = 'v' * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    code = Mobile::AuthenticationService.issue_authorization_code!(user: user, client: Mobile::Client::IOS,
      redirect_uri: Mobile::Client::IOS_REDIRECT_URI, code_challenge: challenge)
    pair = Mobile::AuthenticationService.exchange_authorization_code!(code: code, code_verifier: verifier,
      client_id: Mobile::Client::IOS.id, redirect_uri: Mobile::Client::IOS_REDIRECT_URI, device_name: 'Test device')
    Mobile::AuthenticationService.refresh!(refresh_token: pair[:refresh_token], client_id: Mobile::Client::IOS.id)
    SpamRule.create!(kind: 'email_domain', pattern: user.email.split('@').last)
    assert_raises(Mobile::AuthenticationService::Error) do
      Mobile::AuthenticationService.refresh!(refresh_token: pair[:refresh_token], client_id: Mobile::Client::IOS.id)
    end
    assert_not pair[:device].reload.active?
  end
end
