Sidekiq.default_worker_options = { 'backtrace' => true }
Sidekiq::Extensions.enable_delay!

sidekiq_redis_url = (ENV['REDIS_QUEUE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
channels_redis_url = (ENV['REDIS_CACHE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))

MAIN_REDIS_POOL = ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE', 30), timeout: 5) { Redis.new(url: sidekiq_redis_url) }
CACHE_REDIS_POOL = ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE', 30), timeout: 5) { Redis.new(url: channels_redis_url) }

Redis.exists_returns_integer = false
Redis::Objects.redis = CACHE_REDIS_POOL

if !Rails.env.production? && !ENV['USE_SIDEKIQ']
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
else
  Sidekiq.configure_server do |config|
    config.redis = MAIN_REDIS_POOL
  end

  Sidekiq.configure_client do |config|
    config.redis = MAIN_REDIS_POOL
  end
end
