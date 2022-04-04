class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty
  include Events::Notify::Chatbots

  def self.publish!(
    discussion:,
    actor:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil,
    recipient_message: nil)
    super(discussion,
          user: actor,
          discussion_id: (recipient_message && discussion.id) || nil,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience,
          recipient_message: recipient_message)
  end

  def discussion
    eventable
  end
end
