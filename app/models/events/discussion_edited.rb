class Events::DiscussionEdited < Event
  include Events::Notify::Mentions

  def self.publish!(discussion, editor)
    super discussion,
          user: editor,
          discussion: discussion,
          created_at: discussion.versions.last.created_at
  end
end
