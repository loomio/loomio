class Events::DiscussionDescriptionEdited < Event
  def self.publish!(discussion, editor)
    super discussion, user: editor
  end
end
