Sidekiq.default_worker_options = { 'backtrace' => true }
Sidekiq::Extensions.enable_delay!

sidekiq_redis_url = (ENV['REDIS_QUEUE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379'))
channels_redis_url = (ENV['REDIS_CACHE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379'))

SIDEKIQ_REDIS_POOL = ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE', 30), timeout: 5) { Redis.new(url: sidekiq_redis_url) }
CHANNELS_REDIS_POOL = ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE', 30), timeout: 5) { Redis.new(url: channels_redis_url) }

Redis.exists_returns_integer = false
Redis::Objects.redis = SIDEKIQ_REDIS_POOL

if Rails.env.test? || Rails.env.development?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
else

  Sidekiq.configure_server do |config|
    config.redis = SIDEKIQ_REDIS_POOL
  end

  Sidekiq.configure_client do |config|
    config.redis = SIDEKIQ_REDIS_POOL
  end
end
