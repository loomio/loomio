require 'test_helper'

class ImmutableAssetCacheMiddlewareTest < ActiveSupport::TestCase
  test 'sets immutable cache-control on 200 and 304 responses for hashed vue and client3 assets' do
    app = ImmutableAssetCacheMiddleware.new(->(env) { [ env['TEST_STATUS'] || 200, { 'Cache-Control' => 'public, max-age=3600' }, [ '' ] ] })

    %w[/vue/assets/modal-BUxIIfkI.css /client3/assets/app-1234abcd.js].each do |path|
      [ 200, 304 ].each do |code|
        status, headers, = app.call('PATH_INFO' => path, 'TEST_STATUS' => code)
        assert_equal code, status
        assert_equal 'public, max-age=31536000, immutable', headers['cache-control']
        assert_nil headers['Cache-Control']
      end
    end
  end

  test 'does not set immutable cache-control on non-200/304 responses or non-asset paths' do
    app = ImmutableAssetCacheMiddleware.new(->(env) { [ env['TEST_STATUS'] || 200, { 'cache-control' => 'no-cache' }, [ '' ] ] })

    _, headers_404, = app.call('PATH_INFO' => '/vue/assets/missing.css', 'TEST_STATUS' => 404)
    assert_equal 'no-cache', headers_404['cache-control']

    %w[/vue/index.html /service-worker.js /dashboard].each do |path|
      _, headers, = app.call('PATH_INFO' => path)
      assert_equal 'no-cache', headers['cache-control']
    end
  end
end
