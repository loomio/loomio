class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  include Events::DiscussionParent

  def self.publish!(discussion, editor)
    create(kind: "discussion_edited",
           eventable: discussion.versions.last,
           user: editor,
           parent: lookup_parent(discussion),
           discussion: discussion,
           created_at: discussion.versions.last.created_at).tap { |e| EventBus.broadcast('discussion_edited_event', e) }
  end
end
