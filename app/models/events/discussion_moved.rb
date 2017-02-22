class Events::DiscussionMoved < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor, source)
    create(kind: "discussion_moved",
           eventable: source,
           discussion: discussion,
           user: actor).tap { |e| EventBus.broadcast('discussion_moved_event', e) }
  end
end
