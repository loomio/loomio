class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    create(kind: "discussion_edited",
           eventable: discussion.versions.last,
           user: editor,
           discussion_id: discussion.id).tap { |e| EventBus.broadcast('discussion_edited_event', e) }
  end
end
