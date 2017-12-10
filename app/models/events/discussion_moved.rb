class Events::DiscussionMoved < Event
  include Events::LiveUpdate
  include Events::DiscussionParent

  def self.publish!(discussion, actor, source_group)
    create(kind: "discussion_moved",
           eventable: discussion,
           discussion: discussion,
           parent: lookup_parent(discussion),
           custom_fields: {source_group_id: source_group.id},
           user: actor).tap { |e| EventBus.broadcast('discussion_moved_event', e) }
  end
end
