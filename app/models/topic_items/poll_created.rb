class TopicItems::PollCreated < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(poll, actor)
    super(poll,
          user: actor,
          topic: poll.topic,
          pinned: true)
  end
end
