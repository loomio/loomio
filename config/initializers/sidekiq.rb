Sidekiq.default_worker_options = { 'backtrace' => true }
Sidekiq::Extensions.enable_delay!

redis_url = (ENV['REDIS_QUEUE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379'))

REDIS_POOL = ConnectionPool.new(size: ENV.fetch('REDIS_POOL_SIZE', 30)) { Redis.new(url: redis_url) }

if Rails.env.test? || Rails.env.development?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
else

  Sidekiq.configure_server do |config|
    config.redis = REDIS_POOL
  end

  Sidekiq.configure_client do |config|
    config.redis = REDIS_POOL
  end
end
