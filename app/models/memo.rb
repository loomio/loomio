class Memo
  def self.publish!(thing)
    memo = new(thing)
    memo.publish!
  end

  def as_hash
    {memo: {kind: kind, data: data}}
  end

  def publish!
    if Rails.application.secrets.faye_url.present?
      PrivatePub.publish_to(message_channel, as_hash)
    end
  end
end
