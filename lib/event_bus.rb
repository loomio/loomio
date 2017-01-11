class EventBus

  def self.configure
    yield self
  end

  def self.broadcast(event, *params)
    listeners[event].each { |listener| listener.call(*params) }
  end

  def self.listen(*events, &block)
    events.each { |event| listeners[event].add(block) }
  end

  def self.deafen(*events, &block)
    events.each { |event| listeners[event].delete(block) }
  end

  def self.clear
    @@listeners = nil
  end

  def self.listeners
    @@listeners ||= Hash.new { |hash, key| hash[key] = Set.new }
  end
  private_class_method :listeners

end
