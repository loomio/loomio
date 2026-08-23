class TopicItems::NewDiscussion < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(discussion:)
    super(discussion,
          user: discussion.author,
          topic: discussion.topic)
  end

  def discussion
    itemable
  end
end
