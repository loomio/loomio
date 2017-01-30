class Events::PollClosed < Event
  def self.publish!(poll, actor)
    create(kind: "poll_closed",
           user: actor,
           eventable: poll,
           discussion: poll.discussion,
           created_at: poll.closed_at).tap { |e| EventBus.broadcast('poll_closed_event', e) }
  end
end
