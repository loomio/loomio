module RetryOnError
  def self.with_limit(limit)
    limit.times do |i|
      begin
        return yield i
      rescue => e
        raise e if i + 1 == limit
      end
    end
  end
end
