class Events::OutcomeCreated < Event
  include Events::Notify::Mentions
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Chatbots
  include Events::LiveUpdate
  include Events::Notify::Subscribers

  def self.publish!(
    outcome:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil)
    super(outcome,
          user: outcome.author,
          topic: outcome.poll.topic,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience)
  end
end
