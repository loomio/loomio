class TopicItems::PollEdited < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(
    poll:,
    actor:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_message: nil,
    recipient_audience: nil
  )
    raise ArgumentError, "recipient_message is required" if recipient_message.blank?

    super(poll,
          topic: poll.topic,
          user: actor,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience.presence,
          recipient_message: recipient_message.presence)
  end
end
