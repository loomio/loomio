class Events::PollClosedByUser < Event
  def self.publish!(poll, actor)
    create(kind: "poll_closed_by_user",
           user: actor,
           eventable: poll,
           parent: lookup_parent_event(poll),
           discussion: poll.discussion,
           created_at: poll.closed_at).tap { |e| EventBus.broadcast('poll_closed_by_user_event', e) }
  end
end
