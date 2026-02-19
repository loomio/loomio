class Events::DiscussionReopened < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion,
          user: actor,
          topic: discussion.topic
  end
end
