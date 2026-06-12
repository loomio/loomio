module ThrottleService
  PERIODS = {
    'hour' => 1.hour,
    'day' => 1.day
  }.freeze

  class LimitReached < StandardError
  end

  def self.reset!(per)
    per = normalize_period(per)
    Rails.cache.increment(namespace_cache_key(per), 1, initial: 0)
  end

  def self.can?(key: 'default-key', id: 1, max: 100, inc: 1, per: 'hour')
    per = normalize_period(per)
    limit = ENV.fetch('THROTTLE_MAX_' + key, max).to_i
    count = Rails.cache.increment(cache_key(key: key, id: id, per: per), inc, initial: 0, expires_in: PERIODS.fetch(per))

    count.to_i <= limit
  end

  def self.limit!(key: 'default-key', id: 1, max: 100, inc: 1, per: 'hour')
    if can?(key: key, id: id, max: max, inc: inc, per: per)
      true
    else
      raise ThrottleService::LimitReached.new "Throttled! #{key}-#{id}"
    end
  end

  def self.cache_key(key:, id:, per: 'hour')
    per = normalize_period(per)
    "THROTTLE-#{per.upcase}-#{namespace(per)}-#{key}-#{id}"
  end

  def self.namespace_cache_key(per)
    "THROTTLE-#{per.upcase}-NAMESPACE"
  end

  def self.namespace(per)
    Rails.cache.fetch(namespace_cache_key(per)) { 0 }
  end

  def self.normalize_period(per)
    per.to_s.tap do |period|
      raise "Throttle per is not hour or day: #{per}" unless PERIODS.key?(period)
    end
  end
end
