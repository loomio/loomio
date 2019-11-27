class Events::PollReopened < Event
  def self.publish!(poll, actor)
    create(kind: "poll_reopened",
           user: actor,
           discussion: poll.discussion,
           eventable: poll).tap { |e| EventBus.broadcast('poll_reopened_event', e) }
  end
end
