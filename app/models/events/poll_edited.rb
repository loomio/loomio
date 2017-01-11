class Events::PollEdited < Event
  def self.publish!(poll, actor)
    create(kind: "poll_edited",
           user: actor,
           eventable: poll,
           discussion: poll.discussion,
           created_at: poll.created_at).tap { |e| EventBus.broadcast('poll_edited_event', e) }
  end
end
