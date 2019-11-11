class Events::CommentEdited < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions

  def self.publish!(comment, actor)
    version = comment.versions.last
    super(comment,
          user:          actor,
          custom_fields: {version_id: version.id, changed_keys: (version.object_changes || {}).keys},
          created_at:    version.created_at).tap { |e| EventBus.broadcast('comment_edited_event', e) }
  end
end
