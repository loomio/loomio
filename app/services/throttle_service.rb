module ThrottleService
  def self.can?(key: 'default-key', id: 1, max: 100 , inc: 1, per: 'hour')
    Redis::Counter.new("#{key}#{id}").increment(inc)
    Redis::Counter.new("#{key}#{id}").value <= ENV.fetch('THROTTLE_MAX_'+key, max)
  end

  def self.limit!(key: 'default-key', id: 1, max: 100 , inc: 1, per: 'hour')
    if can?(key: key, id: id, max: max, inc: inc, per: per)
      return true
    else
      raise "Throttled! #{key}#{id}"
    end
  end
end
