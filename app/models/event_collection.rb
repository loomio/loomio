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
    { cache: { reactions: reaction_cache, documents: documents, mentions: mentions } }
  end

  def reaction_cache
    @reaction_cache ||= Caches::Reaction.new(parents: eventables)
  end

  def mentions
    @mentions ||= Comment.find(event_comment_ids).map { |c| [c.id, c.mentioned_usernames] }.to_h
  end

  def documents
    @documents ||= Document.where(
      model_type: "Comment",
      model_id: event_comment_ids
    ).group_by(&:model_id)
  end

  def eventables
    Event.where(id: @events.map(&:id)).includes(:eventable)
    @events.map(&:eventable)
  end

  def event_comment_ids
    @event_comment_ids ||= @events.select { |event| event.kind == 'new_comment' }.map(&:eventable_id)
  end
end
