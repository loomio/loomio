class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    create(kind: "discussion_edited",
           eventable: discussion.versions.last,
           user: editor,
           parent: discussion.created_event,
           discussion: discussion,
           created_at: discussion.versions.last.created_at).tap { |e| EventBus.broadcast('discussion_edited_event', e) }
  end
end
