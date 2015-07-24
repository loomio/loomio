class Memo
  def self.publish!(thing)
    memo = new(thing)
    memo.publish!
  end

  def as_hash
    {memo: {kind: kind, data: data}}
  end

  def publish!
    if ENV['FAYE_URL']
      if ENV['DELAY_FAYE']
        PrivatePub.delay(priority: 10).publish_to(message_channel, as_hash)
      else
        PrivatePub.publish_to(message_channel, as_hash)
      end
    end
  end
end
