class TopicItems::OutcomeCreated < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(outcome:)
    super(outcome,
          user: outcome.author,
          topic: outcome.poll.topic)
  end
end
