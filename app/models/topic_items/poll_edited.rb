class TopicItems::PollEdited < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(poll:, actor:)
    super(poll,
          topic: poll.topic,
          user: actor)
  end
end
