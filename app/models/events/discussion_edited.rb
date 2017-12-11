class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  
  def self.publish!(discussion, editor)
    super discussion.versions.last,
          parent: discussion.created_event,
          discussion: discussion,
          user: editor
  end
end
