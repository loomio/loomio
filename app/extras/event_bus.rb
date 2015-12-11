class EventBus
  include Singleton

  def broadcast(event, *params)
    listeners[event].each { |listener| listener.call(*params) }
  end

  def listen(event, &block)
    listeners[event].add(block)
  end

  def deafen(event, &block)
    listeners[event].delete(block)
  end

  def clear
    @listeners = nil
  end

  private

  def listeners
    @listeners ||= Hash.new { |hash, key| hash[key] = Set.new }
  end

end
