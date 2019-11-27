class Events::DiscussionReopened < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion,
          user: actor,
          discussion: discussion
  end
end
