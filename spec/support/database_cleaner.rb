RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    # DatabaseCleaner[:redis].db = ENV.fetch('REDIS_URL', 'redis://localhost:6379')
    DatabaseCleaner[:active_record].strategy = :transaction
    # DatabaseCleaner[:redis].strategy = :truncation
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    Redis::Objects.redis.flushdb
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
