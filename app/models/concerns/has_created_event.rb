module HasCreatedEvent
  def created_event
    events.find_by(kind: created_event_kind) || create_missing_created_event!
  end

  def created_event_kind
    :"#{self.class.name.downcase}_created"
  end

  def create_missing_created_event!
    nil
  end
end
