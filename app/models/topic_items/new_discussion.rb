class TopicItems::NewDiscussion < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(
    discussion:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil)
    super(discussion,
          user: discussion.author,
          topic: discussion.topic,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience.presence)
  end

  def discussion
    itemable
  end
end
