class Events::DiscussionMoved < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion,
          topic: discussion.topic,
          user: actor,
          created_at: Time.now
  end
end
