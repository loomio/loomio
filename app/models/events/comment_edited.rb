class Events::CommentEdited < Event
  include Events::LiveUpdate

  def self.publish!(comment, actor)
    version = comment.versions.last
    create(kind:          'comment_edited',
           eventable:     comment,
           user:          actor,
           custom_fields: {version_id: version.id, changed_keys: version.object_changes.keys},
           created_at:    version.created_at).tap { |e| EventBus.broadcast('comment_edited_event', e) }
  end
end
