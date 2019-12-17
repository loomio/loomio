module HasCreatedEvent
  def created_event
    events.find_by(kind: created_event_kind)
  end

  def created_event_kind
    :"#{self.class.name.downcase}_created"
  end

  def restore_missing_created_event
    CreateMissingEventService.send(created_event_kind, self)
  end
end
