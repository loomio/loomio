class ImmutableAssetCacheMiddleware
  IMMUTABLE_PREFIXES = %w[/vue/assets/ /client3/assets/].freeze
  CACHE_CONTROL = 'public, max-age=31536000, immutable'.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    path = env['PATH_INFO'].to_s
    if (status == 200 || status == 304) && IMMUTABLE_PREFIXES.any? { |prefix| path.start_with?(prefix) }
      headers = headers.dup
      headers.delete('Cache-Control')
      headers['cache-control'] = CACHE_CONTROL
    end
    [ status, headers, body ]
  end
end
