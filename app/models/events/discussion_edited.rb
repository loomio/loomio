class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  def self.publish!(discussion, editor)
    version = discussion.versions.last
    super discussion,
          user: editor,
          custom_fields: {version_id: version.id, changed_keys: version.object_changes.keys},
          created_at: version.created_at
  end
end
