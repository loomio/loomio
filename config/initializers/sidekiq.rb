Sidekiq.default_job_options = { 'backtrace' => true }

sidekiq_redis_url = (ENV['REDIS_QUEUE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
channels_redis_url = (ENV['REDIS_CACHE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))

# ConnectionPool for Redis::Objects
CACHE_REDIS_POOL = ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE', 30).to_i, timeout: 5) { Redis.new(url: channels_redis_url) }

Redis::Objects.redis = CACHE_REDIS_POOL

if !Rails.env.production? && !ENV['USE_SIDEKIQ']
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
else
  # Sidekiq 7.x manages its own connection pool, so pass a Hash config instead of ConnectionPool
  Sidekiq.configure_server do |config|
    config.redis = { url: sidekiq_redis_url, size: ENV.fetch('REDIS_POOL_SIZE', 30).to_i }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: sidekiq_redis_url, size: ENV.fetch('REDIS_POOL_SIZE', 30).to_i }
  end
end
