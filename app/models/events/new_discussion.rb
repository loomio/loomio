class Events::NewDiscussion < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty
  include Events::Notify::Chatbots

  def self.publish!(
    discussion:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil)

    super(discussion,
          user: discussion.author,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience.presence)
  end

  def discussion
    eventable
  end
end
