class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::WebPush
  include Events::Notify::Chatbots

  def self.publish!(
    discussion:,
    actor:,
    recipient_user_ids:,
    recipient_chatbot_ids:,
    recipient_audience: nil,
    recipient_message: nil)

    super(discussion,
          user: actor,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: recipient_chatbot_ids,
          recipient_audience: recipient_audience.presence,
          recipient_message: recipient_message.presence)
  end
end
