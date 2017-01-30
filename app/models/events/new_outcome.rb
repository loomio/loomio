class Events::NewOutcome < Event
  def self.publish!(outcome)
    create(kind: "new_outcome",
           user: outcome.author,
           eventable: outcome,
           discussion: outcome.discussion,
           created_at: outcome.created_at).tap { |e| EventBus.broadcast('new_outcome_event', e) }
  end
end
