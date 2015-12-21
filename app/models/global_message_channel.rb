class GlobalMessageChannel
  include Singleton

  def message_channel
    '/global'
  end
end
