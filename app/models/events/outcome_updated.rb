class Events::OutcomeUpdated < Event
  include Events::Notify::Mentions
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Chatbots
  include Events::LiveUpdate
  include Events::Notify::Subscribers

  def self.publish!(outcome:,
    actor:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil)
    super(outcome,
          user: actor,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience)
  end
end
