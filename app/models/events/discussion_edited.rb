class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    version = discussion.versions.last
    create(kind: "discussion_edited",
           eventable: discussion,
           user: editor,
           parent: discussion.created_event,
           custom_fields: {version_id: version.id, changed_keys: version.object_changes.keys},
           discussion: discussion,
           created_at: version.created_at).tap { |e| EventBus.broadcast('discussion_edited_event', e) }
  end
end
