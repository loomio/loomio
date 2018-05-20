class Events::DiscussionClosed < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion
          user: actor,
          parent: discussion.created_event,
          discussion: discussion,
          created_at: discussion.closed_at
  end
end
