class Events::DiscussionMoved < Event
  def self.publish!(discussion, actor, source)
    create(kind: "discussion_moved",
           eventable: source,
           discussion: discussion,
           user: actor).tap { |e| EventBus.broadcast('discussion_moved_event', e) }
  end
end
