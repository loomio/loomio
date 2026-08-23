class TopicItems::DiscussionEdited < TopicItem
  include TopicItems::Notify::Chatbots
  include TopicItems::LiveUpdate

  def self.publish!(
    discussion:,
    actor:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil,
    recipient_message: nil)
    raise ArgumentError, "recipient_message is required" if recipient_message.blank?

    super(discussion,
          user: actor,
          topic: discussion.topic,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience,
          recipient_message: recipient_message)
  end

  def discussion
    itemable
  end
end
