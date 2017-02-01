class Events::PollExpired < Event
  def self.publish!(poll)
    create(kind: "poll_expired",
           eventable: poll,
           discussion: poll.discussion,
           created_at: poll.closed_at).tap { |e| EventBus.broadcast('poll_expired_event', e) }
  end
end
