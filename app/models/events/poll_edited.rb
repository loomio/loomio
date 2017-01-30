class Events::PollEdited < Event
  def self.publish!(version, actor)
    create(kind: "poll_edited",
           user: actor,
           eventable: version,
           discussion: version.item.discussion,
           created_at: version.created_at).tap { |e| EventBus.broadcast('poll_edited_event', e) }
  end
end
