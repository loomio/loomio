class ApplicationChannel < ApplicationCable::Channel
  def subscribed
    stream_from GlobalMessageChannel.instance.message_channel
  end
end
