class Memo
  def self.publish!(thing)
    memo = new(thing)
    memo.publish!
  end

  def as_hash
    {memo: {kind: kind, data: data}}
  end

  def publish!
    MessageChannelService.publish_data(as_hash, to: message_channel)
  end
end
