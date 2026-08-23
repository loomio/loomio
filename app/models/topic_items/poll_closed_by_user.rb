class TopicItems::PollClosedByUser < TopicItem
  include TopicItems::Notify::Chatbots
  include TopicItems::LiveUpdate

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          topic: poll.topic,
          created_at: poll.closed_at
  end
end
