class MessageChannelService
  def self.publish(data, to:)
    ActionCable.server.broadcast to.message_channel, data if to.respond_to?(:message_channel)
  end
end
