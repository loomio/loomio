class Events::OutcomeCreated < Event
  include Events::Notify::Mentions
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Chatbots
  include Events::LiveUpdate

  def self.publish!(
    outcome:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_audience: nil)
    super(outcome,
          user: outcome.author,
          discussion: outcome.poll.discussion,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience)
  end
end
