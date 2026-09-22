require 'test_helper'

class AuthenticationThrottlesTest < ActiveSupport::TestCase
  setup do
    @cache_before = Rack::Attack.cache.store
    @enabled_before = Rack::Attack.enabled
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true
    @app = Rack::Attack.new(lambda do |env|
      [200, { 'content-type' => 'application/json' }, [ActionDispatch::Request.new(env).params.to_json]]
    rescue ActionDispatch::Http::Parameters::ParseError
      [400, {}, []]
    end)
  end

  teardown do
    Rack::Attack.cache.store = @cache_before
    Rack::Attack.enabled = @enabled_before
  end

  ['application/json', 'application/x-www-form-urlencoded'].each do |content_type|
    {
      '/api/v1/login_tokens' => [{ email: 'target@example.com' }, 5, 'login_tokens/email'],
      '/api/v1/sessions' => [{ user: { email: 'target@example.com', password: 'secret' } }, 10, 'sessions/email']
    }.each do |path, (params, limit, throttle)|
      test "#{path} limits #{content_type} email attempts across client addresses" do
        limit.times do |index|
          status, _, body = request(path, params, content_type: content_type, ip: "203.0.113.#{index + 1}")
          assert_equal 200, status
          assert_equal params.deep_stringify_keys, JSON.parse(body.join)
        end
        variants = params.deep_dup
        email_params = variants[:user] || variants
        email_params[:email] = ' TARGET@EXAMPLE.COM '
        status, = request(path, variants, content_type: content_type, ip: '203.0.113.99')
        assert_equal 429, status
        assert_equal throttle, @last_env['rack.attack.matched']

        email_params[:email] = 'another@example.com'
        assert_equal 200, request(path, variants, content_type: content_type, ip: '203.0.113.100').first
      end
    end
  end

  test 'JSON codes share a per-email budget across IPs and recover after the window' do
    params = { user: { email: 'code@example.com', code: '123456' } }
    freeze_time do
      5.times do |index|
        assert_equal 200, request('/api/v1/sessions', params, ip: "203.0.113.#{index + 1}").first
      end
      assert_equal 429, request('/api/v1/sessions', params, ip: '203.0.113.99').first
      assert_equal 'sessions/code/email', @last_env['rack.attack.matched']
      travel 16.minutes
      assert_equal 200, request('/api/v1/sessions', params, ip: '203.0.113.100').first
    end
  end

  test 'malformed credentials and invalid JSON do not crash the throttle' do
    [{ user: nil }, { user: 'invalid' }, { user: [] }, { user: { email: [] } }, { email: {} }].each do |params|
      assert_equal 200, request('/api/v1/sessions', params).first
    end
    assert_equal 400, request('/api/v1/sessions', '{invalid', raw: true).first
  end

  private

  def request(path, params, content_type: 'application/json', ip: '203.0.113.1', raw: false)
    body = if raw
      params
    elsif content_type == 'application/json'
      params.to_json
    else
      params.to_query
    end
    @last_env = Rack::MockRequest.env_for(path, method: 'POST', input: body, 'CONTENT_TYPE' => content_type, 'REMOTE_ADDR' => ip)
    @app.call(@last_env)
  end
end
