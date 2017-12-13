class Events::DiscussionClosed < Event
  def self.publish!(discussion, actor)
    create(kind: "discussion_closed",
           eventable: discussion,
           user: actor,
           parent: discussion.created_event,
           discussion: discussion,
           created_at: discussion.closed_at).tap { |e| EventBus.broadcast('discussion_closed', e) }
  end
end
