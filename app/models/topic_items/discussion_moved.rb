class TopicItems::DiscussionMoved < TopicItem
  include TopicItems::LiveUpdate

  def self.publish!(discussion, actor)
    super discussion,
          topic: discussion.topic,
          user: actor,
          created_at: Time.now
  end
end
