module HasCreatedEvent
  def created_event
    events.find_by(kind: created_event_kind)
  end

  def topic_event
    events.where.not(topic_id: nil).first
  end

  def created_event_kind
    :"#{self.class.name.downcase}_created"
  end

  def create_missing_created_event!
    self.events.create(
      kind: created_event_kind,
      user_id: author_id,
      topic: topic,
      created_at: created_at
    )
  end
end
