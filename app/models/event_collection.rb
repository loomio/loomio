class EventCollection
  attr_reader :events

  def initialize(events)
    @events = Array(events)
  end

  def any?
    @events.any?
  end

  def serialize!(scope = {})
    Events::ArraySerializer.new(self, scope: default_scope.merge(scope)).as_json
  end

  private

  def default_scope
    { cache: {} }
  end

  def eventables
    Event.where(id: @events.map(&:id)).includes(:eventable)
    @events.map(&:eventable)
  end

  def event_comment_ids
    @event_comment_ids ||= @events.select { |event| event.kind == 'new_comment' }.map(&:eventable_id)
  end
end
