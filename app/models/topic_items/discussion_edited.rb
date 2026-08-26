class TopicItems::DiscussionEdited < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def discussion
    itemable
  end
end
