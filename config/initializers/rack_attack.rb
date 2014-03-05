Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
Rack::Attack.throttle 'req/ip', limit: 50, period: 1.second do |req| req.ip end
