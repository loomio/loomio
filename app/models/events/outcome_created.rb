class Events::OutcomeCreated < Event
  def self.publish!(outcome)
    create(kind: "outcome_created",
           user: outcome.author,
           eventable: outcome,
           announcement: outcome.make_announcement,
           discussion: outcome.poll.discussion,
           created_at: outcome.created_at).tap { |e| EventBus.broadcast('outcome_created_event', e) }
  end

  def users_to_notify
    eventable.poll.watchers.without(self.user) # maybe just poll participants?
  end
end
