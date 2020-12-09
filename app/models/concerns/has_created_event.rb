module HasCreatedEvent
  def created_event
    events.find_by(kind: created_event_kind)
  end

  def created_event_kind
    :"#{self.class.name.downcase}_created"
  end

  def create_missing_created_event!
    event = self.events.create(kind: created_event_kind, user_id: author_id, created_at: created_at)
    event.reset_sequences
    event
  end
end
