class TopicItems::OutcomeCreated < TopicItem
  include TopicItems::Notify::Chatbots
  include TopicItems::Notify::Subscribers
  include TopicItems::LiveUpdate

  def self.publish!(
    outcome:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil)
    publish_and_mark_read!(outcome,
                           reader: outcome.author,
                           user: outcome.author,
                           topic: outcome.poll.topic,
                           recipient_user_ids: recipient_user_ids,
                           recipient_chatbot_ids: recipient_chatbot_ids,
                           recipient_audience: recipient_audience)
  end
end
