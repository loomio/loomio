class Memo
  def self.publish!(thing)
    memo = new(thing)
    memo.publish!
  end

  def as_hash
    {memo: {kind: kind, data: data}}
  end

  def publish!
    return unless ENV['FAYE_ENABLED'] # remove this soon
    #puts "PrivatePub.publish_to #{message_channel}, #{ as_hash.inspect }"
    PrivatePub.delay(priority: 10).publish_to message_channel, as_hash
  end
end
