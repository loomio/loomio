module ThrottleService
  class LimitReached < StandardError
  end

  def self.reset!(per)
    CHANNELS_REDIS_POOL.with do |client|
      client.scan_each(match: "THROTTLE-#{per.upcase}*") { |key| client.del(key) }
    end
  end

  def self.can?(key: 'default-key', id: 1, max: 100 , inc: 1, per: 'hour')
    raise "Throttle per is not hour or day: #{per}"  unless ['hour', 'day'].include? per.to_s
    k = "THROTTLE-#{per.upcase}-#{key}-#{id}"
    Redis::Counter.new(k).increment(inc)
    Redis::Counter.new(k).value <= ENV.fetch('THROTTLE_MAX_'+key, max)
  end

  def self.limit!(key: 'default-key', id: 1, max: 100 , inc: 1, per: 'hour')
    if can?(key: key, id: id, max: max, inc: inc, per: per)
      return true
    else
      raise ThrottleService::LimitReached.new "Throttled! #{key}-#{id}"
    end
  end
end
