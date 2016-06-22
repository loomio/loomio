class EventCollection
  attr_reader :events

  def initialize(events)
    @events = Array(events)
  end

  def any?
    @events.any?
  end

  def serialize!(scope = {})
    Events::ArraySerializer.new(self, scope: scope).as_json
  end
end
