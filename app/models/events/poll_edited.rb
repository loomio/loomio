class Events::PollEdited < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions

  def self.publish!(poll, actor)
    version = poll.versions.last
    super poll,
          user: actor,
          custom_fields: {version_id: version.id, changed_keys: version.object_changes.keys},
          created_at: version.created_at
  end
end
