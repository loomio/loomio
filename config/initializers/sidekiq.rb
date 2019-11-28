Sidekiq.default_worker_options = { 'backtrace' => true }
Sidekiq::Extensions.enable_delay!

redis_url = (ENV['REDIS_QUEUE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379'))+"/1"
Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
