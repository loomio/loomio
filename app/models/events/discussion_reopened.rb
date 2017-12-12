class Events::DiscussionReopened < Event
  def self.publish!(discussion, actor)
    create(kind: "discussion_reopened",
           eventable: discussion,
           user: actor,
           parent: discussion.created_event,
           discussion: discussion).tap { |e| EventBus.broadcast('discussion_closed', e) }
  end
end
