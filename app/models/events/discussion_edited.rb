class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    super discussion.versions.last,
          parent: discussion.created_event,
          discussion: discussion,
          user: editor
  end
end
