module RSpec
  module RedisHelper

    # When this module is included into the rspec config,
    # it will set up an around(:each) block to clear redis.
    def self.included(rspec)
      rspec.around(:each, redis: true) do |example|
        with_clean_redis do
          example.run
        end
      end
    end

    CONFIG = { url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/1" }

    def redis(&block)
      @redis ||= ::Redis.connect(CONFIG)
    end

    def with_clean_redis(&block)
      redis.flushall            # clean before run
      begin
        yield
      ensure
        redis.flushall          # clean up after run
      end
    end

  end # RedisHelper
end # RSpec
