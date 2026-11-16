require 'test_helper'

class SpamRulesMiddlewareTest < ActiveSupport::TestCase
  setup do
    @rule = SpamRule.create!(kind: 'ip', pattern: '198.51.100.0/24')
    @calls = 0
    @app = SpamRulesMiddleware.new(->(_env) { @calls += 1; [ 200, {}, [ 'Allowed' ] ] })
  end

  test 'IP bans block public signed-in admin API and authentication requests before the app' do
    [ '/', '/admin', '/api/v1/profile', '/api/v1/sessions', '/api/v1/trials', '/api/user0/groups', '/api/v1/mobile/token' ].each do |path|
      status, headers, = @app.call(env(path, ip: '198.51.100.7'))
      assert_equal 403, status, path
      assert_equal 'no-store', headers['cache-control']
    end
    assert_equal 0, @calls
    assert_equal 7, @rule.hits.sum(:count)
  end

  test 'edits and disabled bans take effect on the next request' do
    assert_equal 403, @app.call(env('/', ip: '198.51.100.7')).first
    @rule.discard!
    assert_equal 200, @app.call(env('/', ip: '198.51.100.7')).first
    assert_equal 200, @app.call(env('/', ip: '203.0.113.1')).first
    assert_equal 1, @rule.hits.sum(:count)
  end

  test 'trusted Cloudflare headers select the client while untrusted clients cannot spoof them' do
    trusted = env('/', ip: '173.245.48.5').merge('HTTP_CF_CONNECTING_IP' => '198.51.100.7')
    assert_equal 403, @app.call(trusted).first
    untrusted = env('/', ip: '198.51.100.7').merge('HTTP_CF_CONNECTING_IP' => '203.0.113.1')
    assert_equal 403, @app.call(untrusted).first
    untrusted = env('/', ip: '203.0.113.1').merge('HTTP_CF_CONNECTING_IP' => '198.51.100.7')
    assert_equal 200, @app.call(untrusted).first
  end

  test 'IPv6 clients are matched by CIDR and health checks remain operational' do
    @rule.update!(pattern: '2001:db8::/32')
    assert_equal 403, @app.call(env('/', ip: '2001:db8::123')).first
    assert_equal 200, @app.call(env('/up', ip: '2001:db8::123')).first
    assert_equal 200, @app.call(env('/', ip: '2001:db9::123')).first
  end

  private

  def env(path, ip:)
    Rack::MockRequest.env_for(path).merge('REMOTE_ADDR' => ip)
  end
end
