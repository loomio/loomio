class Events::DiscussionReopened < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion,
          user: actor,
          parent: discussion.created_event,
          discussion: discussion
  end
end
