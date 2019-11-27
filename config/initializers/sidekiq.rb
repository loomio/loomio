Sidekiq.default_worker_options = { 'backtrace' => true }
Sidekiq::Extensions.enable_delay!

Sidekiq.configure_server do |config|
  config.redis = { url: (ENV['REDIS_QUEUE_URL'] || ENV['REDIS_URL'])+"/1" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: (ENV['REDIS_QUEUE_URL'] || ENV['REDIS_URL'])+"/1" }
end
