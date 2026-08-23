class TopicItems::PollClosedByUser < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::LiveUpdate

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          topic: poll.topic,
          created_at: poll.closed_at
  end
end
