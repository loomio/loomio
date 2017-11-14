class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    super discussion.versions.last, user: editor, discussion: discussion
  end
end
