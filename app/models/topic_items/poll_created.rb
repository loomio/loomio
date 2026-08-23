class TopicItems::PollCreated < TopicItem
  include TopicItems::Notify::Chatbots
  include TopicItems::Notify::Subscribers
  include TopicItems::LiveUpdate

  def self.publish!(poll, actor)
    publish_and_mark_read!(poll,
                           reader: actor,
                           user: actor,
                           topic: poll.topic,
                           pinned: true)
  end
end
