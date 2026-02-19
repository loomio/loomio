class Events::DiscussionClosed < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion,
          user: actor,
          topic: discussion.topic,
          created_at: discussion.topic.closed_at
  end
end
