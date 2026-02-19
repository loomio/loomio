module HasCreatedEvent
  def created_event
    events.find_by(kind: created_event_kind)
  end

  def created_event_kind
    :"#{self.class.name.downcase}_created"
  end

  def create_missing_created_event!
    self.events.create(kind: created_event_kind, user_id: author_id, topic: topic_for_created_event, created_at: created_at)
  end

  def topic_for_created_event
    if respond_to?(:topic) && topic.is_a?(Topic)
      topic
    elsif respond_to?(:poll) && poll&.respond_to?(:topic)
      poll.topic
    end
  end
end
