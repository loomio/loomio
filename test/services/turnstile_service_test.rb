require 'test_helper'

class TurnstileServiceTest < ActiveSupport::TestCase
  setup do
    @original_secret = ENV['TURNSTILE_SECRET_KEY']
  end

  teardown do
    ENV['TURNSTILE_SECRET_KEY'] = @original_secret
  end

  test "enabled? follows TURNSTILE_SECRET_KEY presence" do
    ENV['TURNSTILE_SECRET_KEY'] = nil
    refute TurnstileService.enabled?
    ENV['TURNSTILE_SECRET_KEY'] = ''
    refute TurnstileService.enabled?
    ENV['TURNSTILE_SECRET_KEY'] = '   '
    refute TurnstileService.enabled?
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    assert TurnstileService.enabled?
  end

  test "verify returns true when disabled regardless of token" do
    ENV['TURNSTILE_SECRET_KEY'] = nil
    assert TurnstileService.verify(nil)
    assert TurnstileService.verify('')
    assert TurnstileService.verify('anything')
  end

  test "verify rejects empty token when enabled" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    refute TurnstileService.verify(nil)
    refute TurnstileService.verify('')
    refute TurnstileService.verify('   ')
  end

  test "verify hits siteverify and returns true on success" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      with(body: hash_including('secret' => 'test-secret', 'response' => 'cf-token', 'remoteip' => '1.2.3.4')).
      to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    assert TurnstileService.verify('cf-token', remote_ip: '1.2.3.4')
  end

  test "verify returns false when Cloudflare says not success" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).
      to_return(status: 200, body: { success: false, 'error-codes' => ['invalid-input-response'] }.to_json, headers: { 'Content-Type' => 'application/json' })
    refute TurnstileService.verify('bad-token')
  end

  test "verify returns false on non-200 from Cloudflare" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).to_return(status: 500, body: '')
    refute TurnstileService.verify('any-token')
  end

  test "verify returns false on network error" do
    ENV['TURNSTILE_SECRET_KEY'] = 'test-secret'
    WebMock.stub_request(:post, TurnstileService::SITEVERIFY_URL).to_raise(SocketError.new('getaddrinfo fail'))
    refute TurnstileService.verify('any-token')
  end
end
