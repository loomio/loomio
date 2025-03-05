class Events::PollEdited < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::Notify::Subscribers

  def self.publish!(
    poll:,
    actor:,
    recipient_user_ids: [],
    recipient_chatbot_ids: [],
    recipient_message: nil,
    recipient_audience: nil
  )
    super(poll,
          discussion_id: (recipient_message && poll.discussion_id) || nil,
          user: actor,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience.presence,
          recipient_message: recipient_message.presence)
  end
end
